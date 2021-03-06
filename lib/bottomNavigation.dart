import 'package:dartoclock/gamePlaying.dart';
import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: index,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      backgroundColor: Colors.transparent,
      elevation: 0,
      selectedFontSize: 14,
      unselectedFontSize: 14,
      onTap: (value) {
        switch (value) {
          case 0:
            if (ModalRoute.of(context)?.settings?.name != '/game' &&
                ModalRoute.of(context)?.settings?.name != '/gameChoice') {
              GamePlaying.isPlayingAGame
                  ? Navigator.of(context).popUntil(ModalRoute.withName('/game'))
                  : Navigator.of(context)
                      .popUntil(ModalRoute.withName('/gameChoice'));
            }
            break;
          case 1:
            if (ModalRoute.of(context)?.settings?.name != '/rules') {
              Navigator.of(context).pushNamed('/rules');
            }
            break;
          case 2:
            if (ModalRoute.of(context)?.settings?.name != '/statistics') {
              Navigator.of(context).pushNamed('/statistics');
            }
            break;
          case 3:
            if (ModalRoute.of(context)?.settings?.name != '/settings') {
              Navigator.of(context).pushNamed('/settings');
            }
        }
      },
      items: [
        BottomNavigationBarItem(
            label: 'Game', icon: Icon(Icons.play_arrow)),
        BottomNavigationBarItem(
            label: 'Rules', icon: Icon(Icons.library_books)),
        BottomNavigationBarItem(
            label: 'Statistics', icon: Icon(Icons.assessment)),
        BottomNavigationBarItem(
            label: 'Settings', icon: Icon(Icons.settings)),
      ],
    );
  }
}
