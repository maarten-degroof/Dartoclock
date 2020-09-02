import 'package:dartoclock/gameModesEnum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Statistics {
  static double classicGamesStarted;
  static double classicGamesFinished;

  static double countdownGamesStarted;
  static double countdownGamesFinished;

  static double eliminationGamesStarted;
  static double eliminationGamesFinished;
  
  static double playersEliminatedCount;

  static Future<void> _getStatistics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    classicGamesStarted = prefs.getDouble('classicGamesStarted') ?? 0;
    classicGamesFinished = prefs.getDouble('classicGamesFinished') ?? 0;

    countdownGamesStarted = prefs.getDouble('countdownGamesStarted') ?? 0;
    countdownGamesFinished = prefs.getDouble('countdownGamesFinished') ?? 0;

    eliminationGamesStarted = prefs.getDouble('eliminationGamesStarted') ?? 0;
    eliminationGamesFinished = prefs.getDouble('eliminationGamesFinished') ?? 0;
    
    playersEliminatedCount = prefs.getDouble('playersEliminatedCount') ?? 0;
  }

  static Future<void> _saveStatistics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('classicGamesStarted', classicGamesStarted);
    prefs.setDouble('classicGamesFinished', classicGamesFinished);

    prefs.setDouble('countdownGamesStarted', countdownGamesStarted);
    prefs.setDouble('countdownGamesFinished', countdownGamesFinished);

    prefs.setDouble('eliminationGamesStarted', eliminationGamesStarted);
    prefs.setDouble('eliminationGamesFinished', eliminationGamesFinished);

    prefs.setDouble('playersEliminatedCount', playersEliminatedCount);
  }

  static double totalStartedGames() {
    return classicGamesStarted +
        countdownGamesStarted +
        eliminationGamesStarted;
  }

  static double totalFinishedGames() {
    return classicGamesFinished +
        countdownGamesFinished +
        eliminationGamesFinished;
  }

  static void startedGame(GameModes gameMode) {
    switch (gameMode) {
      case GameModes.Classic:
        classicGamesStarted++;
        break;
      case GameModes.Countdown:
        countdownGamesStarted++;
        break;
      case GameModes.Elimination:
        eliminationGamesStarted++;
        break;
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
        break;
      case GameModes.Elimination:
        eliminationGamesFinished++;
        break;
    }
    _saveStatistics();
  }

  static void addOnePlayerEliminated() {
    playersEliminatedCount++;
    _saveStatistics();
  }

  static double getPlayersEliminatedCount() {
    return playersEliminatedCount;
  }

  static void resetStatistics() {
    classicGamesStarted = 0;
    classicGamesFinished = 0;

    countdownGamesStarted = 0;
    countdownGamesFinished = 0;

    eliminationGamesStarted = 0;
    eliminationGamesFinished = 0;

    playersEliminatedCount = 0;

    _saveStatistics();
  }

  static void initialise() {
    // initialise all the stats here
    // call this function when starting the app (in main.dart)
    _getStatistics();
  }
}
