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
  static double totalScoreThrown;
  static double totalRoundsPlayed;

  static Future<void> _loadStatistics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    classicGamesStarted = prefs.getDouble('classicGamesStarted') ?? 0;
    classicGamesFinished = prefs.getDouble('classicGamesFinished') ?? 0;

    countdownGamesStarted = prefs.getDouble('countdownGamesStarted') ?? 0;
    countdownGamesFinished = prefs.getDouble('countdownGamesFinished') ?? 0;

    eliminationGamesStarted = prefs.getDouble('eliminationGamesStarted') ?? 0;
    eliminationGamesFinished = prefs.getDouble('eliminationGamesFinished') ?? 0;

    playersEliminatedCount = prefs.getDouble('playersEliminatedCount') ?? 0;
    totalScoreThrown = prefs.getDouble('totalScoreThrown') ?? 0;
    totalRoundsPlayed = prefs.getDouble('totalRoundsPlayed') ?? 0;
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
    prefs.setDouble('totalScoreThrown', totalScoreThrown);
    prefs.setDouble('totalRoundsPlayed', totalRoundsPlayed);
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

  static void addRoundPlayed() {
    totalRoundsPlayed++;
    _saveStatistics();
  }

  /// Calculates the average amount of rounds played, rounded up so you don't get
  /// 1.5 rounds or 0.3 rounds which would be 0 when rounded down.
  static int getAverageRoundsPlayed() {
    if (totalRoundsPlayed == 0 ||
        (classicGamesStarted == 0 &&
            eliminationGamesStarted == 0 &&
            countdownGamesStarted == 0)) {
      return 0;
    }
    return (totalRoundsPlayed / totalStartedGames()).ceil();
  }

  static double getTotalRoundsPlayed() {
    return totalRoundsPlayed;
  }

  static void addScoreThrown(double score) {
    totalScoreThrown += score;
    _saveStatistics();
  }

  static void removeScoreThrown(double score) {
    totalScoreThrown -= score;
    _saveStatistics();
  }

  static double getTotalScoreThrown() {
    return totalScoreThrown;
  }

  static void resetStatistics() {
    classicGamesStarted = 0;
    classicGamesFinished = 0;

    countdownGamesStarted = 0;
    countdownGamesFinished = 0;

    eliminationGamesStarted = 0;
    eliminationGamesFinished = 0;

    playersEliminatedCount = 0;
    totalScoreThrown = 0;
    totalRoundsPlayed = 0;

    _saveStatistics();
  }

  /// This loads the _loadStatistics function which loads or defaults all the statistics
  /// This is called when the app is started in main.dart
  static void initialise() {
    _loadStatistics();
  }
}
