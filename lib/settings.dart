import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsWindow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: <Widget>[Text('This is the settings window')],
      ),
      bottomNavigationBar: _buildNavigation(context),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 3,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      backgroundColor: Theme.of(context).primaryColor,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      onTap: (value) {
        switch (value) {
          case 0:
            Navigator.of(context).pop();
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
}
