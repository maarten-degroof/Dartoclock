import 'package:dartoclock/BackgroundColorLoader.dart';
import 'package:dartoclock/bottomNavigation.dart';
import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/gamePlaying.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'game.dart';

class GameChoiceScreen extends StatefulWidget {
  @override
  _GameChoiceScreenState createState() => _GameChoiceScreenState();
}

const MAX_USERS = 15;

class _GameChoiceScreenState extends State<GameChoiceScreen> {
  int users = 2;
  String generalBackgroundColor;

  // Vital for identifying our VisibilityDetector when a rebuild occurs.
  final Key visibilityDetectorKey = UniqueKey();

  Column _generateGameModeButtons() {
    Column column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (GameModes mode in GameModes.values)
          RaisedButton(
            onPressed: () {
              GamePlaying.isPlayingAGame = true;
              Navigator.of(context).pushNamed(
                '/game',
                arguments: GameArguments(mode, users),
              );
            },
            child: Text(mode.toString().split('.').last),
          ),
      ],
    );
    return column;
  }

  @override
  void initState() {
    super.initState();

    generalBackgroundColor = 'Blue';
    loadBackgroundColor(null);
  }

  /// (Re-)Loads the background color
  ///
  /// This method is called by the VisibilityDetector. [info] contains information
  /// regarding the visibility.
  void loadBackgroundColor(VisibilityInfo info) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        generalBackgroundColor =
            prefs.getString('generalBackgroundColor') ?? 'Blue';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: visibilityDetectorKey,
      onVisibilityChanged: loadBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: BackgroundColorLoader.getColor(generalBackgroundColor),
        )),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Choose the game mode'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          backgroundColor: Colors.transparent,
          body: ListView(children: [
            Container(
              margin: EdgeInsets.all(14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: users > 1,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            icon: Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                users--;
                              });
                            },
                            padding: EdgeInsets.all(0),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            users.toString() +
                                (users > 1 ? ' players' : ' player'),
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        Visibility(
                          visible: users < MAX_USERS,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: IconButton(
                            icon: Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                users++;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Welcome, choose your game mode to play.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _generateGameModeButtons(),
                  ]),
            ),
          ]),
          bottomNavigationBar: BottomNavigation(index: 0),
        ),
      ),
    );
  }
}
