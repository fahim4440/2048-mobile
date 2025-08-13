part of 'game_bloc.dart';

sealed class GameState extends Equatable {
  const GameState();
}

final class GameInitial extends GameState {
  @override
  List<Object> get props => [];
}

class TileData {
  final int row;
  final int col;
  final int previousRow;
  final int previousCol;
  final int value;
  final bool isMerging;
  final bool isNew;
  final String id;
  final Point<int>? previousPosition;
  final String? mergedFrom; // ID of the tile this was merged from

  const TileData({
    required this.row,
    required this.col,
    required this.previousRow,
    required this.previousCol,
    required this.value,
    this.isMerging = false,
    this.isNew = false,
    required this.id,
    this.previousPosition,
    this.mergedFrom,
  });

  TileData copyWith({
    int? row,
    int? col,
    int? previousRow,
    int? previousCol,
    int? value,
    bool? isMerging,
    bool? isNew,
  }) {
    return TileData(
      row: row ?? this.row,
      col: col ?? this.col,
      previousRow: previousRow ?? this.previousRow,
      previousCol: previousCol ?? this.previousCol,
      value: value ?? this.value,
      isMerging: isMerging ?? this.isMerging,
      isNew: isNew ?? this.isNew,
      id: id,
      previousPosition: previousPosition,
      mergedFrom: mergedFrom,
    );
  }
}

final class GameRun extends GameState {
  final List<List<int>> grid;
  final List<TileData> tiles;
  final int score;
  final bool gameOver;
  final int previousGesture;
  final GameMode gameMode;
  final int? movesLeft; // for Move Limit mode
  final int? timeLeft; // for Time Attack mode (in seconds)
  final int timestamp;

  const GameRun({
    required this.grid,
    required this.tiles,
    required this.score,
    this.gameOver = false,
    required this.previousGesture,
    required this.gameMode,
    this.movesLeft,
    this.timeLeft,
    required this.timestamp,
  });

  GameRun copyWith({
    List<List<int>>? grid,
    List<TileData>? tiles,
    int? score,
    bool? gameOver,
    int? previousGesture,
    int? movesLeft,
    int? timeLeft,
  }) {
    return GameRun(
      grid: grid ?? this.grid,
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      gameOver: gameOver ?? this.gameOver,
      previousGesture: previousGesture ?? this.previousGesture,
      gameMode: gameMode,
      movesLeft: movesLeft ?? this.movesLeft,
      timeLeft: timeLeft ?? this.timeLeft,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  List<Object?> get props => [grid, tiles, score, gameOver, previousGesture, timeLeft, movesLeft];
}

class GameOverState extends GameState {
  final int score;
  final List<List<int>> grid;

  GameOverState({required this.score, required this.grid});

  @override
  List<Object> get props => [score, grid];
}
