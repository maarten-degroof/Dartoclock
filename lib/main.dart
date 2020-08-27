import 'package:dartoclock/rules.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'game.dart';
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
        '/rules': (context) => Rules(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
