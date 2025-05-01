part of 'game_bloc.dart';

sealed class GameState extends Equatable {
  const GameState();
}

final class GameInitial extends GameState {
  @override
  List<Object> get props => [];
}


final class GameRun extends GameState {
  final List<List<int>> grid;
  final int score;
  final bool gameOver;
  final int previousGesture;

  const GameRun({required this.grid, required this.score, this.gameOver = false, required this.previousGesture});

  @override
  List<Object> get props => [grid, score, gameOver, previousGesture];
}

class GameOverState extends GameState {
  final int score;
  final List<List<int>> grid;

  GameOverState({required this.score, required this.grid});

  @override
  List<Object> get props => [score, grid];
}


