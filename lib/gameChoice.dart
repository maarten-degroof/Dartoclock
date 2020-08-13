import 'package:dartoclock/gameModesEnum.dart';
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
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeScreen(GameModes.Classic, users),
                  ));
                },
                child: Text('Classic'),
              )
            ]),
      ),
      bottomNavigationBar: _buildNavigation(context),
    );
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
