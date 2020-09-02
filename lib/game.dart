import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/gamePlaying.dart';
import 'package:dartoclock/history.dart';
import 'package:dartoclock/statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'bottomNavigation.dart';
import 'addPoints.dart';

GameModes gameMode;
int userCount;
bool someoneFinished;

class GameScreen extends StatefulWidget {
  GameScreen() {
    someoneFinished = false;
  }

  @override
  _GameScreenState createState() => _GameScreenState();
}

class GameArguments {
  final GameModes gameMode;
  final int userCount;

  GameArguments(this.gameMode, this.userCount);
}

class _GameScreenState extends State<GameScreen> {
  bool hasSentStatistics;
  static List<PlayerScreen> userList;
  static Random random;

  @override
  void initState() {
    super.initState();
    hasSentStatistics = false;
    userList = List();
    random = Random();
  }

  static Future<dynamic> _showPlayerEliminatedDialog(
      String playerName, BuildContext context) {
    Statistics.finishedGame(gameMode);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Oh no!'),
            content: Text(
                playerName + ' had the lowest score and has been eliminated.'),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('OKAY'))
            ],
          );
        });
  }

  static Future<void> checkPlayersForElimination(BuildContext context) async {
    List<int> playerScores = List();

    userList.forEach((element) {
      // add a number so high you can't ever throw it so this player isn't a problem
      if (element.isPlayerEliminated()) {
        playerScores.add(10000);
      } else {
        playerScores.add(element.getScore());
      }
    });

    print(playerScores.toString());

    // Null values are for users that still have to throw this round
    // Chooses a random player of the players that have all thrown the lowest number
    if (!playerScores.contains(null)) {
      int minimum = playerScores.reduce(min);
      print('minimum: ' + minimum.toString());
      List<int> indexList = _getIndexList(playerScores, minimum);
      print('indexlist: ' + indexList.toString());

      int indexToEliminate = random.nextInt(indexList.length);
      userList.elementAt(indexList[indexToEliminate]).eliminate();
      await _showPlayerEliminatedDialog(
              userList.elementAt(indexList[indexToEliminate]).getPlayerName(),
              context)
          .then((value) {
        userList.forEach((element) {
          element.resetScore();
        });

        // check if there's only one person left -> wins the game
        int playersStillAliveCount = 0;
        int winnerIndex = 0;

        for (int index = 0; index < userList.length; index++) {
          if (!userList.elementAt(index).isPlayerEliminated()) {
            playersStillAliveCount++;
            winnerIndex = index;
          }
        }

        if (playersStillAliveCount == 1) {
          userList.elementAt(winnerIndex).playerWins();
        }
      });
    }
  }

  /// Gets a list of ints and a number
  /// Returns a list of indexes of the places that contain the given number
  static List<int> _getIndexList(List<int> searchList, int numberToSearch) {
    List<int> indexList = List();

    for (int index = 0; index < searchList.length; index++) {
      if (searchList.elementAt(index) == numberToSearch) {
        indexList.add(index);
      }
    }
    return indexList;
  }

  @override
  Widget build(BuildContext context) {
    final GameArguments args = ModalRoute.of(context).settings.arguments;
    gameMode = args.gameMode;
    userCount = args.userCount;

    if (!hasSentStatistics) {
      Statistics.startedGame(gameMode);
      hasSentStatistics = true;
    }

    // If the users haven't been initialised yet, initialise them
    if (userList.isEmpty) {
      for (int i = 1; i <= userCount; i++) {
        userList.add(PlayerScreen(id: i));
      }
    }

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
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text(
                            _loadGameModeDescription(),
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ]),
                    ),
                  ),
                  for (int i = 0; i < userList.length; i++)
                    userList.elementAt(i),
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
        return 'The first one to get their counter to 0 wins.';
      case GameModes.Countdown:
        return 'Throw each number once starting from 20 and going to 1. The first person to throw all 20 numbers wins.';
      case GameModes.Elimination:
        return 'Person with the lowest score is eliminated each round.';
    }
    return 'Oops, something went wrong!';
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

class PlayerScreen extends StatefulWidget {
  PlayerScreen({this.id});
  final int id;
  _PlayerScreenState playerScreenState;

  void eliminate() {
    playerScreenState.eliminatePlayer();
  }

  void playerWins() {
    playerScreenState.playerWon();
  }

  int getScore() {
    return playerScreenState.getScore();
  }

  void resetScore() {
    playerScreenState.resetScore();
  }

  bool isPlayerEliminated() {
    return playerScreenState.isPlayerEliminated();
  }

  String getPlayerName() {
    return playerScreenState.getPlayerName();
  }

  @override
  _PlayerScreenState createState() => playerScreenState = _PlayerScreenState(id: id);
}

class _PlayerScreenState extends State<PlayerScreen> {
  _PlayerScreenState({this.id});
  final int id;
  String name;
  final _textFieldController = TextEditingController();

  int score;
  int gameStartScore;

  int currentCountdownThrow;
  final countDownStart = 20;

  bool playerIsEliminated;
  bool playerWins = false;

  var previousScoreList = [];

  @override
  void initState() {
    super.initState();
    name = 'Player $id';

    _getSharedPrefs();
    currentCountdownThrow = countDownStart;

    playerIsEliminated = false;

    // initialise the ELIMINATION game variables
    if (gameMode == GameModes.Elimination) {
      score = null;
    }
  }

  /// Loads the startScore from the shared preferences,
  /// or if they haven't been set/altered yet, loads them with the
  /// default value of 360.
  Future<void> _getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gameStartScore = prefs.getInt('classicPoints') ?? 360;
      score = gameStartScore;
      if (gameMode == GameModes.Elimination) {
        score = null;
      }
    });
  }

  int getScore() {
    return score;
  }

  String getPlayerName() {
    return name;
  }

  void eliminatePlayer() {
    setState(() {
      playerIsEliminated = true;
    });
  }

  void playerWon() {
    setState(() {
      someoneFinished = true;
      playerWins = true;
    });
    _showWinningDialog();
  }

  bool isPlayerEliminated() {
    return playerIsEliminated;
  }

  void resetScore() {
    setState(() {
      score = null;
    });
  }

  Widget _buildNameRow() {
    // Set the original player name in the textField
    _textFieldController.text = name;

    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Hero(
              tag: id.toString() + '_user',
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
      case GameModes.Elimination:
        return _buildEliminationGame();
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

  Text _buildEliminationStatusTextField() {
    if (playerIsEliminated) {
      return Text('You are eliminated!',
          style: TextStyle(color: Colors.red, fontSize: 16));
    } else if (playerWins) {
      return Text('You won!! Congratulations!',
          style: TextStyle(color: Colors.green, fontSize: 16));
    } else if (score != null) {
      return Text(
        'Wait until everyone has thrown this round.',
        style: TextStyle(fontSize: 16),
      );
    } else {
      return Text('You\'re up, give it your best!',
          style: TextStyle(color: Colors.green, fontSize: 16));
    }
  }

  Widget _buildEliminationGame() {
    return Column(children: [
      _buildEliminationStatusTextField(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlineButton(
            onPressed: (isPlayerEliminated() || playerWins || score != null)
                ? null
                : () async {
                    final result =
                        await Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddPointsScreen(score, name, id, null, gameMode),
                      transitionDuration: Duration(milliseconds: 1000),
                    ));
                    if (result != null) {
                      setState(() {
                        score = result;
                        _GameScreenState.checkPlayersForElimination(context);
                      });
                    }
                  },
            child: Text('Add a throw')),
      ]),
      Container(
        margin: EdgeInsets.all(10),
        child: Text(
          score == null ? '' : 'You threw: ' + score.toString(),
          style: TextStyle(fontSize: 16),
        ),
      )
    ]);
  }

  Widget _buildCountdownGame() {
    return Column(children: [
      Hero(
        tag: id.toString() + '_score',
        child: Material(
          color: Colors.transparent,
          child: Text(
            'Score to throw: ' + currentCountdownThrow.toString(),
            style: TextStyle(fontSize: 18, backgroundColor: Colors.transparent),
          ),
        ),
      ),
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
          onPressed: () {
            setState(() {
              if (currentCountdownThrow > 0) {
                currentCountdownThrow--;
              }
              if (currentCountdownThrow == 0 && !someoneFinished) {
                playerWon();
              }
            });
          },
          child: Text(
            'I threw it',
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
                      name, previousScoreList, score, gameStartScore)));
            },
          ),
        ),
      ]),
      Container(
          margin: EdgeInsets.all(12),
          child: Text(
            _buildCountdownThrowsTextField(),
            style: TextStyle(height: 1.5),
          )),
    ]);
  }

  Widget _buildClassicGame() {
    return Column(children: [
      Hero(
        tag: id.toString() + '_score',
        child: Material(
          color: Colors.transparent,
          child: Text(
            'Score to throw: ' + score.toString(),
            style: TextStyle(fontSize: 18, backgroundColor: Colors.transparent),
          ),
        ),
      ),
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
            onPressed: () async {
              final result = await Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AddPointsScreen(
                        score, name, id, _generatePreviousThrow(), gameMode),
                transitionDuration: Duration(milliseconds: 1000),
              ));
              if (result != null) {
                setState(() {
                  score = score - result;
                  previousScoreList.add(score);
                  if (score == 0 && !someoneFinished) {
                    playerWon();
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
                      name, previousScoreList, score, gameStartScore)));
            },
          ),
        ),
      ]),
      Container(
        margin: EdgeInsets.all(12),
        child: Hero(
          tag: id.toString() + '_previous_throw',
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
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Stack(
        children: [
          Hero(
            tag: id.toString() + "_backIcon",
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
          Positioned.fill(
            child: Hero(
              tag: id.toString() + "_background",
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(width: 5, color: _getPlayerColor()),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withAlpha(70),
                          offset: Offset(3.0, 10.0),
                          blurRadius: 15.0),
                    ]),
                margin: EdgeInsets.all(3.0),
              ),
            ),
          ),
          Column(children: [
            _buildNameRow(),
            _buildGameMode(),
          ]),
        ],
      ),
    );
  }

  /// This decides which border color the user gets
  Color _getPlayerColor() {
    if (playerWins) {
      return Colors.green;
    } else if (playerIsEliminated) {
      return Colors.red;
    } else {
      return Colors.transparent;
    }
  }

  Future<dynamic> _showWinningDialog() {
    Statistics.finishedGame(gameMode);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Game won!'),
            content: Text('Good news, ' +
                name +
                ' won the game! Do you want to finish the game?'),
            actions: <Widget>[
              new FlatButton(
                  child: new Text('FINISH'),
                  onPressed: () {
                    GamePlaying.isPlayingAGame = false;
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('/gameChoice'));
                  }),
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
        lastThrownScore = gameStartScore - previousScoreList.last;
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
                          ? score = gameStartScore
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
        text += (gameStartScore - previousScoreList.last).toString();
      } else {
        text += (previousScoreList[previousScoreList.length - 2] -
                previousScoreList.last)
            .toString();
      }
    }
    return text;
  }
}
