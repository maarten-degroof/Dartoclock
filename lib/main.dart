import 'package:dartoclock/gameModesEnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                child: Text(
                  gameMode.toString().split('.').last + ' game',
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            for (int i=1; i<=userCount; i++) UserScreen(name: 'Player $i'),
          ],
        ),
      ]),
      bottomNavigationBar: _buildNavigation(context),
    );
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
            builder: (context) => SettingsWindow(),
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

class _UserScreenState extends State<UserScreen> {
  _UserScreenState() {
    score = startScore;
  }
  final _textFieldController = TextEditingController();
  int score;
  int startScore = 300;

  var previousScoreList = [];

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
                      builder: (context) => AddPointsScreen(
                          startScore: score, user: widget.name)));
              if (result != null) {
                setState(() {
                  score = result;
                  previousScoreList.add(result);
                });
              }
            },
            child: Text(
              score.toString(),
              style: TextStyle(fontSize: 18),
            ),
          ),
        ]),
        Text(
          'History',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
        _generateHistoryTextView()
      ]),
    );
  }

  Future<dynamic> _showUndoDialog() {
    int lastThrownScore;
    if (previousScoreList.length == 1) {
      lastThrownScore = startScore - previousScoreList.last;
    } else {
      lastThrownScore =
          previousScoreList.elementAt(previousScoreList.length - 2) -
              previousScoreList.elementAt(previousScoreList.length - 1);
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
                    previousScoreList.removeLast();
                    previousScoreList.isEmpty
                        ? score = startScore
                        : score = previousScoreList.last;
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

  Container _generateHistoryTextView() {
    String text = "";
    if (previousScoreList.isEmpty) {
      text = 'There\'s no history yet';
    } else {
      int newScore = startScore;
      for (int score in previousScoreList) {
        int difference = newScore - score;
        text += (score.toString() + ' (-' + difference.toString() + ('); '));
        newScore = score;
      }
    }

    return Container(
        margin: EdgeInsets.all(10),
        child: Text(
          text,
        ));
  }
}
