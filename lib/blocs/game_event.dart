part of 'game_bloc.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();
}

class SwipeUpEvent extends GameEvent {
  @override
  List<Object?> get props => [];
}
class SwipeDownEvent extends GameEvent {
  @override
  List<Object?> get props => [];
}
class SwipeLeftEvent extends GameEvent {
  @override
  List<Object?> get props => [];
}
class SwipeRightEvent extends GameEvent {
  @override
  List<Object?> get props => [];
}
class ResetGameEvent extends GameEvent {
  @override
  List<Object?> get props => [];
}

class GameStartEvent extends GameEvent {
  @override
  List<Object?> get props => [];
}