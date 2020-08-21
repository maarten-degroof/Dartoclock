/// Static class to check if the player is currently playing a game.
/// This is used in the bottom navigation to know where to go to.
class GamePlaying {
  static bool isPlayingAGame = false;

  static void toggleIsPlayingAGame() {
    isPlayingAGame = !isPlayingAGame;
  }
}
