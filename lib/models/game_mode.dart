enum GameMode {
  classic,
  timeAttack,
  moveLimit;

  String get displayName {
    switch (this) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.timeAttack:
        return 'Time Attack';
      case GameMode.moveLimit:
        return 'Move Limit';
    }
  }

  String get description {
    switch (this) {
      case GameMode.classic:
        return 'Classic 2048 game. Merge tiles to reach 2048 and more!';
      case GameMode.timeAttack:
        return 'Race against time! Score as high as possible in 3 minutes.';
      case GameMode.moveLimit:
        return 'Only 50 moves! Make them count.';
    }
  }
}
