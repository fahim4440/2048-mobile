import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:match2048/models/game_mode.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameMode gameMode;
  Timer? _gameTimer;
  static const int timeAttackDuration = 180; // 3 minutes
  static const int moveLimitCount = 50;
  int _tileIdCounter = 0;

  GameBloc({required this.gameMode}) : super(GameInitial()) {
    on<SwipeUpEvent>(
      (event, emit) async => await _handleSwipe(Direction.up, emit),
    );
    on<SwipeDownEvent>(
      (event, emit) async => await _handleSwipe(Direction.down, emit),
    );
    on<SwipeLeftEvent>(
      (event, emit) async => await _handleSwipe(Direction.left, emit),
    );
    on<SwipeRightEvent>(
      (event, emit) async => await _handleSwipe(Direction.right, emit),
    );
    on<ResetGameEvent>((event, emit) => _resetGame(emit));
    on<GameStartEvent>((event, emit) => _startGame(event, emit));
    on<TimerTickEvent>((event, emit) => _handleTimerTick(emit));
  }

  void _startTimer() {
    if (gameMode == GameMode.timeAttack) {
      _gameTimer?.cancel();
      _gameTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => add(TimerTickEvent()),
      );
    }
  }

  void _handleTimerTick(Emitter<GameState> emit) {
    if (state is GameRun) {
      final currentState = state as GameRun;
      final newTimeLeft = (currentState.timeLeft ?? 0) - 1;

      if (newTimeLeft <= 0) {
        _gameTimer?.cancel();
        emit(GameOverState(score: currentState.score, grid: currentState.grid));
      } else {
        emit(currentState.copyWith(timeLeft: newTimeLeft));
      }
    }
  }

  void _checkGameModeConditions(GameRun currentState, Emitter<GameState> emit) {
    switch (gameMode) {
      case GameMode.timeAttack:
        if (currentState.timeLeft! <= 0) {
          emit(GameOverState(
              score: currentState.score, grid: currentState.grid));
        }
        break;
      case GameMode.moveLimit:
        if (currentState.movesLeft! <= 0) {
          emit(GameOverState(
              score: currentState.score, grid: currentState.grid));
        }
        break;
      default:
        break;
    }
  }

  void _startGame(GameStartEvent event, Emitter<GameState> emit) {
    gameMode = event.gameMode;
    _tileIdCounter = 0;
    var newTiles = <TileData>[];
    _addRandomTile(newTiles);
    _addRandomTile(newTiles);

    emit(
      GameRun(
        grid: _gridFromTiles(newTiles),
        tiles: newTiles,
        score: 0,
        previousGesture: -1,
        gameMode: gameMode,
        timeLeft: gameMode == GameMode.timeAttack ? timeAttackDuration : null,
        movesLeft: gameMode == GameMode.moveLimit ? moveLimitCount : null,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _startTimer();
  }

  Future<void> _handleSwipe(Direction direction, Emitter<GameState> emit) async {
    if (state is! GameRun) return;
    final currentState = state as GameRun;

    if (gameMode == GameMode.moveLimit && currentState.movesLeft! <= 0) {
      return;
    }
    
    var tiles = currentState.tiles.map((t) => t.copyWith(isNew: false, isMerging: false)).toList();
    var originalTiles = tiles.map((t) => t.copyWith()).toList();
    var score = 0;

    bool isVertical = direction == Direction.up || direction == Direction.down;
    bool isReversed = direction == Direction.down || direction == Direction.right;

    for (int i = 0; i < 4; i++) {
      var line = tiles.where((t) => isVertical ? t.col == i : t.row == i).toList();
      line.sort((a, b) => (isVertical ? a.row.compareTo(b.row) : a.col.compareTo(b.col)));
      if (isReversed) {
        line = line.reversed.toList();
      }

      var newLine = <TileData>[];
      for(var tile in line) {
        if(newLine.isEmpty) {
          newLine.add(tile);
        } else {
          var last = newLine.last;
          if(last.value == tile.value && !last.isMerging) {
            var merged = last.copyWith(value: last.value * 2, isMerging: true);
            score += merged.value;
            newLine[newLine.length - 1] = merged;
            tiles.removeWhere((t) => t.id == tile.id);
          } else {
            newLine.add(tile);
          }
        }
      }

      for(int j=0; j<newLine.length; j++) {
        var tile = newLine[j];
        var newRow = isVertical ? (isReversed ? 3 - j : j) : i;
        var newCol = isVertical ? i : (isReversed ? 3 - j : j);
        var index = tiles.indexWhere((t) => t.id == tile.id);
        if(index != -1) {
          tiles[index] = tile.copyWith(previousRow: tile.row, previousCol: tile.col, row: newRow, col: newCol);
        }
      }
    }

    bool moved = false;
    if (tiles.length != originalTiles.length) {
      moved = true;
    } else {
      for (var tile in tiles) {
        var original = originalTiles.firstWhere((ot) => ot.id == tile.id);
        if (original.row != tile.row || original.col != tile.col) {
          moved = true;
          break;
        }
      }
    }

    print('GameBloc: Swipe ${direction.name}, Moved: $moved');
    if (moved) {
      await Future.delayed(const Duration(milliseconds: 100));
      _addRandomTile(tiles);

      int? newMovesLeft = currentState.movesLeft;
      if (gameMode == GameMode.moveLimit) {
        newMovesLeft = currentState.movesLeft! - 1;
      }

      final finalState = GameRun(
        grid: _gridFromTiles(tiles),
        tiles: tiles,
        score: currentState.score + score,
        previousGesture: direction.index,
        gameMode: gameMode,
        timeLeft: currentState.timeLeft,
        movesLeft: newMovesLeft,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      emit(finalState);

      if (_isGameOver(finalState.tiles)) {
        emit(GameOverState(score: finalState.score, grid: finalState.grid));
        return;
      }

      _checkGameModeConditions(finalState, emit);
    }
  }

  void _addRandomTile(List<TileData> tiles) {
    var emptyCells = <Point<int>>[];
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (tiles.every((t) => t.row != r || t.col != c)) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      var cell = emptyCells[Random().nextInt(emptyCells.length)];
      tiles.add(
        TileData(
          id: 'tile-${_tileIdCounter++}',
          row: cell.x,
          col: cell.y,
          previousRow: cell.x,
          previousCol: cell.y,
          value: Random().nextInt(10) == 0 ? 4 : 2,
          isNew: true,
        ),
      );
    }
  }

  bool _isGameOver(List<TileData> tiles) {
    if (tiles.length < 16) return false;

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final tile = tiles.firstWhere((t) => t.row == i && t.col == j, orElse: () => TileData(id: '', value: -1, row: -1, col: -1, previousRow: -1, previousCol: -1));
        if (tile.value == -1) continue; // Should not happen in a full grid

        // Check for adjacent tiles with the same value
        // Check right
        if (j < 3) {
          final rightTile = tiles.firstWhere((t) => t.row == i && t.col == j + 1, orElse: () => TileData(id: '', value: -1, row: -1, col: -1, previousRow: -1, previousCol: -1));
          if (rightTile.value != -1 && rightTile.value == tile.value) return false;
        }
        // Check down
        if (i < 3) {
          final downTile = tiles.firstWhere((t) => t.row == i + 1 && t.col == j, orElse: () => TileData(id: '', value: -1, row: -1, col: -1, previousRow: -1, previousCol: -1));
          if (downTile.value != -1 && downTile.value == tile.value) return false;
        }
      }
    }
    return true;
  }

  void _resetGame(Emitter<GameState> emit) {
    emit(GameInitial());
  }

  List<List<int>> _gridFromTiles(List<TileData> tiles) {
    var grid = List.generate(4, (_) => List.generate(4, (_) => 0));
    for (var tile in tiles) {
      grid[tile.row][tile.col] = tile.value;
    }
    return grid;
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    return super.close();
  }
}

enum Direction { up, down, left, right }