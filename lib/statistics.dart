import 'package:dartoclock/gameModesEnum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statistics {
  static double classicGamesStarted;
  static double classicGamesFinished;

  static double countdownGamesStarted;
  static double countdownGamesFinished;

  static Future<void> _getStatistics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    classicGamesStarted = prefs.getDouble('classicGamesStarted') ?? 0;
    classicGamesFinished = prefs.getDouble('classicGamesFinished') ?? 0;

    countdownGamesStarted = prefs.getDouble('countdownGamesStarted') ?? 0;
    countdownGamesFinished = prefs.getDouble('countdownGamesFinished') ?? 0;
  }

  static Future<void> _saveStatistics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('classicGamesStarted', classicGamesStarted);
    prefs.setDouble('classicGamesFinished', classicGamesFinished);

    prefs.setDouble('countdownGamesStarted', countdownGamesStarted);
    prefs.setDouble('countdownGamesFinished', countdownGamesFinished);
  }

  static double totalStartedGames() {
    return classicGamesStarted + countdownGamesStarted;
  }

  static double totalFinishedGames() {
    return classicGamesFinished + countdownGamesFinished;
  }

  static void startedGame(GameModes gameMode) {
    switch (gameMode) {
      case GameModes.Classic:
        classicGamesStarted++;
        break;
      case GameModes.Countdown:
        countdownGamesStarted++;
    }
    _saveStatistics();
  }

  static void finishedGame(GameModes gameMode) {
    switch (gameMode) {
      case GameModes.Classic:
        classicGamesFinished++;
        break;
      case GameModes.Countdown:
        countdownGamesFinished++;
    }
    _saveStatistics();
  }

  static void initialise() {
    // initialise all the stats here
    // call this function when starting the app (in main.dart)
    _getStatistics();
  }
}
