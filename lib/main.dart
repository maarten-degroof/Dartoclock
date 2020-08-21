import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/gamePlaying.dart';
import 'package:dartoclock/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'BottomNavigation.dart';
import 'addPoints.dart';
import 'gameChoice.dart';
import 'settings.dart';

void main() {
  runApp(DartApp());
}

class DartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dartoclock',
      initialRoute: '/gameChoice',
      routes: {
        '/gameChoice': (context) => GameChoiceScreen(),
        '/game': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

GameModes gameMode;
int userCount;
bool someoneFinished;

class HomeScreen extends StatefulWidget {
  HomeScreen() {
    someoneFinished = false;
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class HomeArguments {
  final GameModes gameMode;
  final int userCount;

  HomeArguments(this.gameMode, this.userCount);
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final HomeArguments args = ModalRoute.of(context).settings.arguments;
    gameMode = args.gameMode;
    userCount = args.userCount;

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color.fromRGBO(245, 68, 113, 1.0),
          Color.fromRGBO(245, 161, 81, 1.0),
        ],
      )),
      child: WillPopScope(
        onWillPop: _showQuitGameDialog,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Dartoclock'),
            leading: IconButton(
                icon: Icon(Icons.stop), onPressed: _showQuitGameDialog),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          backgroundColor: Colors.transparent,
          body: ListView(children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Center(
                      child: Column(children: [
                        Text(
                          gameMode.toString().split('.').last + ' game',
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        Text(
                          _loadGameModeDescription(),
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                    ),
                  ),
                  for (int i = 1; i <= userCount; i++)
                    UserScreen(name: 'Player $i'),
                ],
              ),
            ),
          ]),
          bottomNavigationBar: BottomNavigation(
            index: 0,
          ),
          //bottomNavigationBar: _buildNavigation(context),
        ),
      ),
    );
  }

  String _loadGameModeDescription() {
    switch (gameMode) {
      case GameModes.Classic:
        return 'The first one to get their counter to 0 wins';
        break;
      case GameModes.Countdown:
        return 'Throw each number once starting from 20. The first one to 1 and throw it wins';
    }
    return '';
  }

  /// This shows the dialog that asks if you want to quit the current game
  /// So you can choose a different game mode or start over
  Future<bool> _showQuitGameDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Quit current game'),
            content: Text(
                'Are you sure you want to quit the current game and go back to the window to choose a game mode?'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('QUIT'),
                onPressed: () {
                  GamePlaying.isPlayingAGame = false;
                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/gameChoice'));
                  return true;
                },
              ),
              new FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    return false;
                  },
                  child: new Text('CANCEL'))
            ],
          );
        });
  }
}

class UserScreen extends StatefulWidget {
  UserScreen({this.name});
  final String name;
  @override
  _UserScreenState createState() => _UserScreenState(name: name);
}

class _UserScreenState extends State<UserScreen> {
  _UserScreenState({this.name});
  String name;
  final _textFieldController = TextEditingController();
  int score;
  int startScore;
  int currentCountdownThrow;
  final countDownStart = 20;

  var previousScoreList = [];

  @override
  void initState() {
    super.initState();
    _getSharedPrefs();
    currentCountdownThrow = countDownStart;
  }

  /// Loads the startScore from the shared preferences,
  /// or if they haven't been set/altered yet, loads them with the
  /// default value of 360.
  Future<void> _getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      startScore = prefs.getInt('classicPoints') ?? 360;
      score = startScore;
    });
  }

  Widget _buildNameRow() {
    // Set the original player name in the textField
    _textFieldController.text = name;

    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Hero(
              tag: name + '_user',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Editing player name'),
                      content: TextField(
                        maxLength: 20,
                        controller: _textFieldController,
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('SAVE'),
                          onPressed: () {
                            if (_textFieldController.text.length > 0) {
                              setState(() {
                                name = _textFieldController.text;
                              });
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        )
                      ],
                    );
                  });
            },
          )
        ],
      ),
    );
  }

  Widget _buildGameMode() {
    switch (gameMode) {
      case GameModes.Countdown:
        return _buildCountdownGame();
        break;
      default:
        return _buildClassicGame();
    }
  }

  String _buildCountdownThrowsTextField() {
    String textBuilder = '';
    for (int i = countDownStart; i > 0; i--) {
      // If i is bigger, the throw has already been completed
      if (i > currentCountdownThrow) {
        textBuilder += '✔' + i.toString() + '    ';
      } else {
        textBuilder += '❌' + i.toString() + '    ';
      }
    }
    return textBuilder;
  }

  Widget _buildCountdownGame() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible: currentCountdownThrow < countDownStart,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IconButton(
            icon: Icon(Icons.undo),
            onPressed: _showUndoDialog,
          ),
        ),
        OutlineButton(
          textColor: Colors.green,
          onPressed: () {
            setState(() {
              if (currentCountdownThrow > 0) {
                currentCountdownThrow--;
              }
              if (currentCountdownThrow == 0 && !someoneFinished) {
                someoneFinished = true;
                _showWinningDialog();
              }
            });
          },
          child: Text(
            currentCountdownThrow.toString(),
            style: TextStyle(fontSize: 18),
          ),
        ),
        Visibility(
          visible: previousScoreList.isNotEmpty,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HistoryWindow(
                      name, previousScoreList, score, startScore)));
            },
          ),
        ),
      ]),
      Container(
          margin: EdgeInsets.all(10.0),
          child: Text(
            _buildCountdownThrowsTextField(),
            style: TextStyle(height: 1.5),
          )),
    ]);
  }

  Widget _buildClassicGame() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible: previousScoreList.isNotEmpty,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IconButton(
            icon: Icon(Icons.undo),
            onPressed: _showUndoDialog,
          ),
        ),
        OutlineButton(
            textColor: Colors.green,
            onPressed: () async {
              final result = await Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AddPointsScreen(
                        startScore: score,
                        user: name,
                        previousThrowText: _generatePreviousThrow()),
                transitionDuration: Duration(milliseconds: 1000),
              ));
              if (result != null) {
                setState(() {
                  score = result;
                  previousScoreList.add(result);
                  if (score == 0 && !someoneFinished) {
                    setState(() {
                      someoneFinished = true;
                      _showWinningDialog();
                    });
                  }
                });
              }
            },
            child: Text('Add a throw')),
        Visibility(
          visible: previousScoreList.isNotEmpty,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HistoryWindow(
                      name, previousScoreList, score, startScore)));
            },
          ),
        ),
      ]),
      Container(
        margin: EdgeInsets.all(10),
        child: Hero(
          tag: name + '_previous_throw',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Previous throw: ' + _generatePreviousThrow(),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 30.0),
      child: Stack(
        children: [
          Hero(
            tag: name + "_backIcon",
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                height: 0,
                width: 0,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: null,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                return showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Editing player name'),
                        content: TextField(
                          maxLength: 20,
                          controller: _textFieldController,
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('SAVE'),
                            onPressed: () {
                              if (_textFieldController.text.length > 0) {
                                setState(() {
                                  name = _textFieldController.text;
                                });
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          )
                        ],
                      );
                    });
              },
            ),
          ),
          Positioned.fill(
            child: Hero(
              tag: name + "_background",
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(70),
                          offset: Offset(3.0, 10.0),
                          blurRadius: 15.0)
                    ]),
                margin: EdgeInsets.all(3.0),
              ),
            ),
          ),
          Column(children: [
            _buildNameRow(),
            Padding(
              padding: EdgeInsets.all(10),
              child: Hero(
                tag: name + '_score',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Score to throw: ' + score.toString(),
                    style: TextStyle(
                        fontSize: 18, backgroundColor: Colors.transparent),
                  ),
                ),
              ),
            ),
            _buildGameMode(),
          ]),
        ],
      ),
    );
  }

  Future<dynamic> _showWinningDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Game won!'),
            content: Text('Good news, ' +
                name +
                ' won the game! Do you want to finish the game? (You can always'
                    ' finish the game by pressing the stop icon in '
                    'the top right of the screen.)'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('FINISH'),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => GameChoiceScreen()),
                      (route) => false);
                },
              ),
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('CANCEL'))
            ],
          );
        });
  }

  Future<dynamic> _showUndoDialog() {
    int lastThrownScore;
    if (gameMode == GameModes.Classic) {
      if (previousScoreList.length == 1) {
        lastThrownScore = startScore - previousScoreList.last;
      } else {
        lastThrownScore =
            previousScoreList.elementAt(previousScoreList.length - 2) -
                previousScoreList.elementAt(previousScoreList.length - 1);
      }
    } else if (gameMode == GameModes.Countdown) {
      lastThrownScore = currentCountdownThrow + 1;
    }

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Undo previous move'),
            content: Text(
                'Are you sure you want to Undo the previous move? You threw a score of ' +
                    lastThrownScore.toString() +
                    ' that turn.'),
            actions: <Widget>[
              new FlatButton(
                child: new Text('UNDO'),
                onPressed: () {
                  setState(() {
                    if (gameMode == GameModes.Classic) {
                      previousScoreList.removeLast();
                      previousScoreList.isEmpty
                          ? score = startScore
                          : score = previousScoreList.last;
                    } else if (gameMode == GameModes.Countdown) {
                      currentCountdownThrow++;
                    }
                  });

                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('CANCEL'))
            ],
          );
        });
  }

  /// Generates the number that was thrown, or says 'this is your first throw',
  /// if no throws have been thrown.
  String _generatePreviousThrow() {
    String text = "";
    if (previousScoreList.isEmpty) {
      text = 'This is your first throw';
    } else {
      if (previousScoreList.length == 1) {
        text += (startScore - previousScoreList.last).toString();
      } else {
        text += (previousScoreList[previousScoreList.length - 2] -
                previousScoreList.last)
            .toString();
      }
    }
    return text;
  }
}
