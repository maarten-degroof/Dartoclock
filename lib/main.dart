import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addPoints.dart';
import 'settings.dart';
import 'gameChoice.dart';

void main() {
  runApp(DartApp());
}

class DartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Dartoclock', home: GameChoiceScreen());
  }
}

GameModes gameMode;
int userCount;

class HomeScreen extends StatefulWidget {
  HomeScreen(GameModes selectedGameMode, chosenUserCount) {
    gameMode = selectedGameMode;
    userCount = chosenUserCount;
    someoneFinished = false;
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dartoclock'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.stop), onPressed: _showQuitGameDialog)
        ],
      ),
      body: ListView(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(12),
              child: Center(
                child: Column(children: [
                  Text(
                    gameMode.toString().split('.').last + ' game',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(fontSize: 20),
                  ),
                  Text(_loadGameModeDescription())
                ]),
              ),
            ),
            for (int i = 1; i <= userCount; i++) UserScreen(name: 'Player $i'),
          ],
        ),
      ]),
      bottomNavigationBar: _buildNavigation(context),
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
  }

  /// This shows the dialog that asks if you want to quit the current game
  /// So you can choose a different game mode or start over
  Future<dynamic> _showQuitGameDialog() {
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
}

/// This builds the bottom navigation bar
Widget _buildNavigation(BuildContext context) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: 0,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white60,
    backgroundColor: Theme.of(context).primaryColor,
    selectedFontSize: 14,
    unselectedFontSize: 14,
    onTap: (value) {
      switch (value) {
        case 3:
          Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (context) => SettingsScreen(),
          ));
      }
    },
    items: [
      BottomNavigationBarItem(
          title: Text('Game'), icon: Icon(Icons.play_arrow)),
      BottomNavigationBarItem(title: Text('Unknown'), icon: Icon(Icons.help)),
      BottomNavigationBarItem(
          title: Text('Rules'), icon: Icon(Icons.library_books)),
      BottomNavigationBarItem(
          title: Text('Settings'), icon: Icon(Icons.settings))
    ],
  );
}

class UserScreen extends StatefulWidget {
  UserScreen({this.name});
  String name;
  @override
  _UserScreenState createState() => _UserScreenState();
}

bool someoneFinished;

class _UserScreenState extends State<UserScreen> {
  final _textFieldController = TextEditingController();
  int score;
  int startScore;
  int currentCountdownThrow;
  final countDownStart = 20;

  var previousScoreList = [];

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
    currentCountdownThrow = countDownStart;
  }

  Future<void> getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      startScore = prefs.getInt('classicPoints') ?? 360;
      score = startScore;
    });
  }

  Widget _buildNameRow() {
    // Set the original player name in the textField
    _textFieldController.text = widget.name;

    return Center(
      heightFactor: 1.2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(widget.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5,
                overflow: TextOverflow.ellipsis),
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
                        controller: _textFieldController,
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('SAVE'),
                          onPressed: () {
                            if (_textFieldController.text.length > 0) {
                              setState(() {
                                widget.name = _textFieldController.text;
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

  Widget _buildGameModeRow() {
    switch (gameMode) {
      case GameModes.Classic:
        return _buildClassicScoreColumn();
        break;
      case GameModes.Countdown:
        return _buildCountdownScoreColumn();
        break;
    }
  }

  String _buildCountdownTextField() {
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

  Widget _buildCountdownScoreColumn() {
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
              };
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
                      widget.name, previousScoreList, score, startScore)));
            },
          ),
        ),
      ]),
      Container(
          margin: EdgeInsets.all(10.0),
          child: Text(
            _buildCountdownTextField(),
            style: TextStyle(height: 1.5),
          )),
    ]);
  }

  Widget _buildClassicScoreColumn() {
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
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddPointsScreen(startScore: score, user: widget.name)));
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
          child: Text(
            score.toString(),
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
                      widget.name, previousScoreList, score, startScore)));
            },
          ),
        ),
      ]),
      Container(
        margin: EdgeInsets.all(10),
        child: Text(
          'Previous throw: ' + _generatePreviousThrow(),
          style: TextStyle(fontSize: 16),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
          border: Border.all(width: 3.0),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        _buildNameRow(),
        _buildGameModeRow(),
      ]),
    );
  }

  Future<dynamic> _showWinningDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Game won!'),
            content: Text('Good news, ' +
                widget.name +
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
