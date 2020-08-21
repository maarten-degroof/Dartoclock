import 'package:dartoclock/bottomNavigation.dart';
import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/gamePlaying.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class GameChoiceScreen extends StatefulWidget {
  @override
  _GameChoiceScreenState createState() => _GameChoiceScreenState();
}

class _GameChoiceScreenState extends State<GameChoiceScreen> {
  int users = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color.fromRGBO(77, 85, 225, 1.0),
          Color.fromRGBO(93, 167, 231, 1.0),
        ],
      )),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Choose the game mode'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Container(
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
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.white),
                      onPressed: users == 1
                          ? null
                          : () {
                              setState(() {
                                users--;
                              });
                            },
                      padding: EdgeInsets.all(0),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        users.toString() + (users > 1 ? ' players' : ' player'),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          users++;
                        });
                      },
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
                RaisedButton(
                  onPressed: () {
                    GamePlaying.isPlayingAGame = true;
                    Navigator.of(context).pushNamed(
                      '/game',
                      arguments: HomeArguments(GameModes.Classic, users),
                    );
                  },
                  child: Text('Classic'),
                ),
                RaisedButton(
                  onPressed: () {
                    GamePlaying.isPlayingAGame = true;
                    Navigator.of(context).pushNamed(
                      '/game',
                      arguments: HomeArguments(GameModes.Countdown, users),
                    );
                  },
                  child: Text('Countdown'),
                ),
              ]),
        ),
        bottomNavigationBar: BottomNavigation(index: 0),
      ),
    );
  }
}
