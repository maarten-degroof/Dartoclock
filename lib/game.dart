import 'dart:async';
import 'dart:math';

import 'package:dartoclock/BackgroundColorLoader.dart';
import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/gamePlaying.dart';
import 'package:dartoclock/history.dart';
import 'package:dartoclock/statistics.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'addPoints.dart';
import 'bottomNavigation.dart';

GameModes gameMode;
int userCount;
bool someoneFinished;
int round;

class GameScreen extends StatefulWidget {
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

  static Timer newRoundDialogTimer;

  String gameBackgroundColor;

  // Vital for identifying our VisibilityDetector when a rebuild occurs.
  final Key visibilityDetectorKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    hasSentStatistics = false;
    userList = List();
    random = Random();
    someoneFinished = false;
    round = 1;
    gameBackgroundColor = 'Red';
    loadBackgroundColor(null);
  }

  static void checkRoundForUpdate(BuildContext context) {
    bool shouldUpdateRound = true;

    // Check if every player has played this round
    userList.forEach((element) {
      shouldUpdateRound = shouldUpdateRound &&
          (element.hasPlayedRound() || element.isPlayerEliminated());
    });

    if (shouldUpdateRound) {
      _addRound(context);
      // Make sure that the timer is canceled if the dialog is closed:
      // The timer will stay active if the user closed the dialog themselves
      _showRoundUpdate(context).then((val) {
        if (newRoundDialogTimer.isActive) {
          newRoundDialogTimer.cancel();
        }
      });
      userList.forEach((element) {
        element.setHasPlayedRound(false);
      });
    }
  }

  /// Increases the round by one and adds this new round to the statistics.
  static void _addRound(BuildContext context) {
    final _GameScreenState stateObject =
        context.findAncestorStateOfType<_GameScreenState>();
    stateObject.setState(() {
      round++;
      Statistics.addRoundPlayed();
    });
  }

  /// Shows a dialog with the new round number. This dialog is hidden after
  /// 2 seconds.
  static Future<dynamic> _showRoundUpdate(BuildContext context) {
    // After 2 seconds, hide the dialog again
    newRoundDialogTimer = Timer(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 1000),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return CustomDialogWidget(
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Wrap(children: [
                  Center(
                    child: Text('Round $round', style: TextStyle(fontSize: 22)),
                  ),
                ]);
              },
            ),
          );
        });
  }

  static Future<dynamic> _showPlayerEliminatedDialog(
      String playerName, BuildContext context) {
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 1000),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return ClassicGeneralDialogWidget(
            titleText: 'Oh no!',
            contentText:
                playerName + ' had the lowest score and has been eliminated.',
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OKAY'))
            ],
          );
        });
  }

  /// Eliminates all the players that haven't won the game
  static void eliminateAllLostPlayers() {
    userList.forEach((player) {
      if (!player.hasPlayerWon() && !player.isPlayerEliminated()) {
        player.eliminate();
      }
    });
  }

  static Future<void> checkPlayersForElimination(BuildContext context) async {
    List<int> playerScores = List();

    userList.forEach((player) {
      // add a number so high you can't ever throw it so this player isn't a problem
      if (player.isPlayerEliminated()) {
        playerScores.add(10000);
      } else if (!player.hasPlayedRound()) {
        playerScores.add(null);
      } else {
        playerScores.add(player.getScore());
      }
    });

    // Null values are for players that still have to throw this round
    // Chooses a random player of the players that have all thrown the lowest number
    if (!playerScores.contains(null)) {
      int minimum = playerScores.reduce(min);
      List<int> indexList = _getIndexList(playerScores, minimum);

      int indexToEliminate = random.nextInt(indexList.length);
      userList.elementAt(indexList[indexToEliminate]).eliminate();
      await _showPlayerEliminatedDialog(
              userList.elementAt(indexList[indexToEliminate]).getPlayerName(),
              context)
          .then((value) {
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
        } else {
          checkRoundForUpdate(context);
          userList.forEach((element) {
            element.setHasPlayedRound(false);
            element.resetScore();
          });
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

  /// (Re-)Loads the background color
  ///
  /// This method is called by the VisibilityDetector. [info] contains information
  /// regarding the visibility.
  void loadBackgroundColor(VisibilityInfo info) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        gameBackgroundColor = prefs.getString('gameBackgroundColor') ?? 'Red';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameArguments args = ModalRoute.of(context).settings.arguments;
    gameMode = args.gameMode;
    userCount = args.userCount;

    if (!hasSentStatistics) {
      Statistics.startedGame(gameMode);
      // Only these game modes use rounds for now
      if (gameMode == GameModes.Classic || gameMode == GameModes.Elimination) {
        Statistics.addRoundPlayed();
      }
      hasSentStatistics = true;
    }

    // If the users haven't been initialised yet, initialise them
    if (userList.isEmpty) {
      for (int i = 1; i <= userCount; i++) {
        userList.add(PlayerScreen(id: i));
      }
    }

    return VisibilityDetector(
      key: visibilityDetectorKey,
      onVisibilityChanged: loadBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: BackgroundColorLoader.getColor(gameBackgroundColor),
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
                          _buildRoundText(),
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
                    ShowUpList(
                      direction: Direction.horizontal,
                      animationDuration: Duration(milliseconds: 1200),
                      delayBetween: Duration(milliseconds: 600),
                      offset: -0.2,
                      children: <Widget>[
                        for (int i = 0; i < userList.length; i++)
                          userList.elementAt(i)
                      ],
                    ),
                  ],
                ),
              ),
            ]),
            bottomNavigationBar: BottomNavigation(
              index: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundText() {
    return Text(
      'Round: ' + round.toString(),
      textAlign: TextAlign.center,
      softWrap: true,
      style: TextStyle(fontSize: 20, color: Colors.white),
    );
  }

  String _loadGameModeDescription() {
    switch (gameMode) {
      case GameModes.Classic:
        return 'The first one to get their score to 0 wins.';
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
    return showAnimatedDialog(
      animationType: DialogTransitionType.size,
      curve: Curves.easeInOut,
      duration: Duration(seconds: 1),
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return ClassicGeneralDialogWidget(
          titleText: 'Quit current game',
          contentText:
              'Are you sure you want to quit the current game and go back to the window to choose a game mode?',
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  return false;
                },
                child: Text('CANCEL')),
            TextButton(
              child: Text('QUIT'),
              onPressed: () {
                GamePlaying.isPlayingAGame = false;
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('/gameChoice'));
                return true;
              },
            ),
          ],
        );
      },
    );
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

  bool hasPlayerWon() {
    return playerScreenState.hasPlayerWon();
  }

  bool hasPlayedRound() {
    return playerScreenState.hasPlayedRound();
  }

  void setHasPlayedRound(bool round) {
    playerScreenState.setHasPlayedRound(round);
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
  _PlayerScreenState createState() =>
      playerScreenState = _PlayerScreenState(id: id);
}

class _PlayerScreenState extends State<PlayerScreen> {
  _PlayerScreenState({this.id});
  final int id;
  String name;
  final _textFieldController = TextEditingController();
  bool hasUndoneMove;
  bool roundPlayed;

  int score;
  int gameStartScore;

  int currentCountdownThrow;
  final countDownStart = 20;
  bool shouldThrowBullsEyeCountdown;
  bool hasThrownBullsEyeCountdown;

  bool playerIsEliminated;
  bool playerWins = false;

  List<int> previousScoreList = List();

  @override
  void initState() {
    super.initState();
    name = 'Player $id';
    hasUndoneMove = false;
    roundPlayed = false;

    shouldThrowBullsEyeCountdown = false;
    hasThrownBullsEyeCountdown = false;

    _getSharedPrefs();
    currentCountdownThrow = countDownStart;

    playerIsEliminated = false;

    // initialise the ELIMINATION game variables
    if (gameMode == GameModes.Elimination) {
      score = null;
    }
  }

  bool hasPlayerWon() {
    return playerWins;
  }

  bool hasPlayedRound() {
    return roundPlayed;
  }

  void setHasPlayedRound(bool hasPlayedThisRound) {
    setState(() {
      roundPlayed = hasPlayedThisRound;
    });
  }

  /// Loads the startScore from the shared preferences,
  /// or if they haven't been set/altered yet, loads them with the
  /// default value of 360.
  Future<void> _getSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gameStartScore = prefs.getInt('classicPoints') ?? 360;
      score = gameStartScore;

      shouldThrowBullsEyeCountdown =
          prefs.getBool('shouldThrowBullseyeCountdown') ?? false;

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
      Statistics.addOnePlayerEliminated();
    });
  }

  void playerWon() {
    setState(() {
      someoneFinished = true;
      playerWins = true;
    });
    _showWinningDialog();
    _GameScreenState.eliminateAllLostPlayers();
  }

  void playerLost() {
    setState(() {
      playerIsEliminated = true;
    });
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
              _textFieldController.text = name;
              return showAnimatedDialog(
                  animationType: DialogTransitionType.size,
                  curve: Curves.easeInOut,
                  duration: Duration(seconds: 1),
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return CustomDialogWidget(
                      title: Text('Editing player name'),
                      content: TextField(
                        maxLength: 20,
                        controller: _textFieldController,
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('CANCEL')),
                        TextButton(
                          child: Text('SAVE'),
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
                        ),
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

  RichText _buildCountdownThrowsTextField() {
    WidgetSpan checkIcon =
        WidgetSpan(child: Icon(Icons.check, color: Colors.green));
    TextSpan span = TextSpan(
        style: TextStyle(height: 2, color: Colors.black), children: []);

    for (int throwNumber = countDownStart; throwNumber > 0; throwNumber--) {
      // If i is bigger, the throw has already been completed
      if (throwNumber > currentCountdownThrow) {
        span.children.add(checkIcon);
        span.children.add(TextSpan(text: throwNumber.toString() + '\t\t'));
      } else {
        span.children
            .add(TextSpan(text: '❌' + throwNumber.toString() + '\t\t'));
      }
    }

    span.children.add(_addBullseyeToCountdownTextField());

    return RichText(text: span);
  }

  TextSpan _addBullseyeToCountdownTextField() {
    if (shouldThrowBullsEyeCountdown) {
      return TextSpan(children: [
        hasThrownBullsEyeCountdown
            ? WidgetSpan(child: Icon(Icons.check, color: Colors.green))
            : TextSpan(text: '❌'),
        WidgetSpan(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Icon(Icons.notifications),
          ),
        ),
      ]);
    }
    return TextSpan(text: ' ');
  }

  Text _buildStatusTextField() {
    if (playerIsEliminated) {
      return Text('You are eliminated!',
          style: TextStyle(color: Colors.red, fontSize: 16));
    } else if (playerWins) {
      return Text('You won!! Congratulations!',
          style: TextStyle(color: Colors.green, fontSize: 16));
    } else if (roundPlayed) {
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
      _buildStatusTextField(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        OutlineButton(
            onPressed: (isPlayerEliminated() || playerWins || roundPlayed)
                ? null
                : () async {
                    final result = await Navigator.of(context).push(
                        PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                AddPointsScreen(
                                    score, name, id, null, gameMode),
                            transitionDuration: Duration(milliseconds: 1000),
                            reverseTransitionDuration:
                                Duration(milliseconds: 1000)));
                    if (result != null) {
                      setState(() {
                        roundPlayed = true;
                        score = result;
                        Statistics.addScoreThrown(result.toDouble());
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

  String _buildScoreToThrowCountDownGame() {
    if (currentCountdownThrow > 0) {
      return 'Score to throw: ' + currentCountdownThrow.toString();
    } else if (shouldThrowBullsEyeCountdown && !hasThrownBullsEyeCountdown) {
      return 'You should throw the bullseye now';
    } else if (playerWins) {
      return 'You won!';
    }
    return 'You finished it, but you\'re not first.';
  }

  Widget _buildCountdownGame() {
    return Column(children: [
      Text(
        _buildScoreToThrowCountDownGame(),
        style: TextStyle(fontSize: 18),
      ),
      _buildStatusTextField(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        OutlinedButton(
            onPressed: (playerWins || playerIsEliminated || roundPlayed)
                ? null
                : () {
                    setState(() {
                      roundPlayed = true;
                      _GameScreenState.checkRoundForUpdate(context);
                    });
                  },
            child: Text('❌ I missed')),
        OutlinedButton.icon(
          onPressed: (playerWins || playerIsEliminated || roundPlayed)
              ? null
              : () {
                  setState(() {
                    roundPlayed = true;
                    if (currentCountdownThrow > 0) {
                      Statistics.addScoreThrown(
                          currentCountdownThrow.toDouble());
                      currentCountdownThrow--;
                    } else if (shouldThrowBullsEyeCountdown) {
                      hasThrownBullsEyeCountdown = true;
                      Statistics.addScoreThrown(50);
                    }
                    if (currentCountdownThrow == 0 &&
                        (!shouldThrowBullsEyeCountdown ||
                            (shouldThrowBullsEyeCountdown &&
                                hasThrownBullsEyeCountdown))) {
                      if (!someoneFinished) {
                        playerWon();
                      } else {
                        playerLost();
                      }
                    } else {
                      _GameScreenState.checkRoundForUpdate(context);
                    }
                  });
                },
          icon: Icon(Icons.check, color: Colors.green),
          label: Text(
            'I threw it',
          ),
        ),
      ]),
      Container(
        margin: EdgeInsets.all(12),
        child: _buildCountdownThrowsTextField(),
      ),
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
      _buildStatusTextField(),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Visibility(
          visible: previousScoreList.isNotEmpty,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: IconButton(
            icon: Icon(Icons.undo),
            onPressed: (hasUndoneMove || playerWins || playerIsEliminated)
                ? null
                : _showUndoDialog,
          ),
        ),
        OutlineButton(
            onPressed: (playerIsEliminated || playerWins || roundPlayed)
                ? null
                : () async {
                    final result =
                        await Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AddPointsScreen(score, name, id,
                              _generatePreviousThrow(), gameMode),
                      transitionDuration: Duration(milliseconds: 1000),
                      reverseTransitionDuration: Duration(milliseconds: 1000),
                    ));
                    if (result != null) {
                      setState(() {
                        hasUndoneMove = false;
                        roundPlayed = true;
                        score = score - result;
                        previousScoreList.add(score);
                        Statistics.addScoreThrown(result.toDouble());

                        if (score == 0 && !someoneFinished) {
                          playerWon();
                        } else {
                          _GameScreenState.checkRoundForUpdate(context);
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
    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 1500),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return Stack(children: [
            ClassicGeneralDialogWidget(
              titleText: 'Game won!',
              contentText: 'Good news, $name won the game' +
                  (gameMode == GameModes.Countdown ? '' : ' in $round rounds') +
                  '! Do you want to finish the game?',
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('CANCEL')),
                TextButton(
                    child: Text('FINISH'),
                    onPressed: () {
                      GamePlaying.isPlayingAGame = false;
                      Navigator.of(context)
                          .popUntil(ModalRoute.withName('/gameChoice'));
                    }),
              ],
            ),
            Fireworks(
              delay: 2,
            )
          ]);
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

    return showAnimatedDialog(
        animationType: DialogTransitionType.size,
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 1000),
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return ClassicGeneralDialogWidget(
            titleText: 'Undo previous move',
            contentText:
                'Are you sure you want to undo the previous move? You threw a score of ' +
                    lastThrownScore.toString() +
                    ' that turn.',
            actions: <Widget>[
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('CANCEL')),
              TextButton(
                child: Text('UNDO'),
                onPressed: () {
                  setState(() {
                    hasUndoneMove = true;
                    if (gameMode == GameModes.Classic) {
                      Statistics.removeScoreThrown(
                          previousScoreList.last.toDouble());
                      previousScoreList.removeLast();
                      previousScoreList.isEmpty
                          ? score = gameStartScore
                          : score = previousScoreList.last;
                    } else if (gameMode == GameModes.Countdown) {
                      currentCountdownThrow++;
                      Statistics.removeScoreThrown(
                          currentCountdownThrow.toDouble());
                    }
                  });

                  Navigator.of(context).pop();
                },
              ),
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
