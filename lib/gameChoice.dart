import 'package:dartoclock/BottomNavigation.dart';
import 'package:dartoclock/gameModesEnum.dart';
import 'package:dartoclock/gamePlaying.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'settings.dart';

class GameChoiceScreen extends StatefulWidget {
  @override
  _GameChoiceScreenState createState() => _GameChoiceScreenState();
}

class _GameChoiceScreenState extends State<GameChoiceScreen> {
  int users = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose the game mode'),
      ),
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
                    icon: Icon(Icons.remove),
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
                      users.toString() + ' users',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
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
                style: TextStyle(fontSize: 18),
              ),
              RaisedButton(
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
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
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
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
    );
  }
}
