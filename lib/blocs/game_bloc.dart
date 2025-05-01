import 'package:bloc/bloc.dart';
import 'dart:math';
import 'package:equatable/equatable.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitial()) {
    on<SwipeUpEvent>((event, emit) async => await _handleSwipe(Direction.up, emit));
    on<SwipeDownEvent>((event, emit) async => await _handleSwipe(Direction.down, emit));
    on<SwipeLeftEvent>((event, emit) async => await _handleSwipe(Direction.left, emit));
    on<SwipeRightEvent>((event, emit) async => await _handleSwipe(Direction.right, emit));
    on<ResetGameEvent>((event, emit) => _resetGame(emit));
    on<GameStartEvent>((event, emit) => _startGame(emit));
  }

  static List<List<int>> _initGrid() {
    var grid = List.generate(4, (_) => List.generate(4, (_) => 0));
    _addRandomTile(grid);
    _addRandomTile(grid);
    return grid;
  }

  static bool _isGridChanged(List<List<int>> oldGrid, List<List<int>> newGrid) {
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (oldGrid[i][j] != newGrid[i][j]) {
          return true; // Grid has changed
        }
      }
    }
    return false; // No change
  }

  static void _addRandomTile(List<List<int>> grid) {
    List<Point> emptyCells = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid[i][j] == 0) emptyCells.add(Point(i, j));
      }
    }
    if (emptyCells.isNotEmpty) {
      var randomCell = emptyCells[Random().nextInt(emptyCells.length)];
      grid[randomCell.x.toInt()][randomCell.y.toInt()] = 2;
    }
  }

  Future<void> _handleSwipe(Direction direction, Emitter<GameState> emit) async {
    if (state is! GameRun) return;
    List<List<int>> newGrid = _copyGrid((state as GameRun).grid);
    int score = (state as GameRun).score;
    bool hasMerged = false;
    int newGesture = 0;
    bool isSameAsPrevious = false;

    // Before making a move, check if game over conditions are met
    if (_isGameOver(newGrid)) {
      emit(GameOverState(score: score, grid: newGrid)); // Emit GameOverState
      return; // Stop the game
    }

    switch (direction) {
      case Direction.up:
        Map<String, dynamic> values = _moveUp(newGrid, emit, hasMerged);
        newGrid = values['grid'];
        score = values['score'];
        hasMerged = values['hasMerged'];
        isSameAsPrevious = !values['isSameAsPrevious'];
        newGesture = 0;
        break;
      case Direction.down:
        Map<String, dynamic> values = _moveDown(newGrid, emit, hasMerged);
        newGrid = values['grid'];
        score = values['score'];
        hasMerged = values['hasMerged'];
        newGesture = 1;
        isSameAsPrevious = !values['isSameAsPrevious'];
        break;
      case Direction.left:
        Map<String, dynamic> values = _moveLeft(newGrid, emit, hasMerged);
        newGrid = values['grid'];
        score = values['score'];
        hasMerged = values['hasMerged'];
        newGesture = 2;
        isSameAsPrevious = !values['isSameAsPrevious'];
        break;
      case Direction.right:
        Map<String, dynamic> values = _moveRight(newGrid, emit, hasMerged);
        newGrid = values['grid'];
        score = values['score'];
        hasMerged = values['hasMerged'];
        newGesture = 3;
        isSameAsPrevious = !values['isSameAsPrevious'];
        break;
    }
    if (!hasMerged) {
      _addRandomTile(newGrid);
      emit(GameRun(grid: newGrid, score: (state as GameRun).score + score, previousGesture: newGesture));
    } else {
      emit(GameRun(grid: newGrid, score: (state as GameRun).score + score, previousGesture: newGesture));
    }
  }

  // Move Left with score accumulation
  Map<String, dynamic> _moveLeft(List<List<int>> grid, Emitter<GameState> emit, bool hasMerged) {
    int score = 0;
    List<List<int>> previousGrid = grid;

    for (int row = 0; row < 4; row++) {
      List<int> rowList = [];
      // Collect all non-zero values in the row
      for (int col = 0; col < 4; col++) {
        if (grid[row][col] != 0) rowList.add(grid[row][col]);
      }

      // Merge tiles in the row
      for (int i = 0; i < rowList.length - 1; i++) {
        if (rowList[i] == rowList[i + 1]) {
          rowList[i] *= 2;
          score += rowList[i];  // Add merged value to the score
          rowList.removeAt(i + 1); // Remove merged tile
          rowList.add(0); // Add 0 to maintain length
          hasMerged = true; // Set merge flag to true
        }
      }

      // Place the updated row back into the grid
      for (int i = 0; i < 4; i++) {
        grid[row][i] = i < rowList.length ? rowList[i] : 0;
      }
    }

    return {
      'grid': grid,
      'hasMerged': hasMerged,
      'score': score,
      'isSameAsPrevious': _isGridChanged(previousGrid, grid),
    };
  }

  // Move Right with score accumulation
  Map<String, Object> _moveRight(List<List<int>> grid, Emitter<GameState> emit, bool hasMerged) {
    int score = 0;
    List<List<int>> previousGrid = grid;

    for (int row = 0; row < 4; row++) {
      List<int> rowList = [];

      // Step 1: Collect all non-zero values in the row (starting from right to left)
      for (int col = 3; col >= 0; col--) {
        if (grid[row][col] != 0) rowList.add(grid[row][col]);
      }

      // Step 2: Merge tiles in the row (from right to left)
      for (int i = 0; i < rowList.length - 1; i++) {
        if (rowList[i] == rowList[i + 1]) {
          rowList[i] *= 2; // Merge tiles by doubling the value
          score += rowList[i]; // Add merged value to the score
          rowList.removeAt(i + 1); // Remove the second tile
          rowList.add(0); // Add 0 at the end to maintain length
          hasMerged = true; // Set merge flag to true
        }
      }

      // Step 3: Fill the row from right to left to place the updated tiles
      for (int i = 0; i < 4; i++) {
        grid[row][3 - i] = i < rowList.length ? rowList[i] : 0;
      }
    }

    // Step 4: Emit updated state with merged score
    return {
      'grid': grid,
      'hasMerged': hasMerged,
      'score': score,
      'isSameAsPrevious': _isGridChanged(previousGrid, grid),
    };
  }

  // Move Up with score accumulation
  Map<String, dynamic> _moveUp(List<List<int>> grid, Emitter<GameState> emit, bool hasMerged) {
    int score = 0;
    List<List<int>> previousGrid = grid;

    for (int col = 0; col < 4; col++) {
      List<int> column = [];

      // Collect all non-zero values in the column
      for (int row = 0; row < 4; row++) {
        if (grid[row][col] != 0) column.add(grid[row][col]);
      }

      // Merge tiles in the column (from top to bottom)
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i] == column[i + 1]) {
          column[i] *= 2; // Merge tiles by doubling the value
          score += column[i]; // Add merged value to score
          column.removeAt(i + 1); // Remove the second tile
          column.add(0); // Add 0 at the end to maintain the same length
          hasMerged = true; // Set merge flag to true
        }
      }

      // Fill the column with updated values from top to bottom
      for (int i = 0; i < 4; i++) {
        grid[i][col] = i < column.length ? column[i] : 0;
      }
    }

    return {
      'grid': grid,
      'hasMerged': hasMerged,
      'score': score,
      'isSameAsPrevious': _isGridChanged(previousGrid, grid),
    };
  }

  // Move Down with score accumulation
  Map<String, Object> _moveDown(List<List<int>> grid, Emitter<GameState> emit, bool hasMerged) {
    int score = 0;
    List<List<int>> previousGrid = grid;

    for (int col = 0; col < 4; col++) {
      List<int> column = [];

      // Collect all non-zero values in the column (from bottom to top)
      for (int row = 3; row >= 0; row--) {
        if (grid[row][col] != 0) column.add(grid[row][col]);
      }

      // Merge tiles in the column (from bottom to top)
      for (int i = 0; i < column.length - 1; i++) {
        if (column[i] == column[i + 1]) {
          column[i] *= 2; // Merge tiles by doubling the value
          score += column[i]; // Add merged value to score
          column.removeAt(i + 1); // Remove the second tile
          column.add(0); // Add 0 at the start to maintain the length
          hasMerged = true; // Set merge flag to true
        }
      }

      // Fill the column from bottom to top to place the updated tiles
      for (int i = 0; i < 4; i++) {
        grid[3 - i][col] = i < column.length ? column[i] : 0; // Fill from bottom up
      }
    }

    // Emit updated state with merged score
    return {
      'grid': grid,
      'hasMerged': hasMerged,
      'score': score,
      'isSameAsPrevious': _isGridChanged(previousGrid, grid),
    };
  }

  //Game Over
  bool _isGameOver(List<List<int>> grid) {
    // 1. Check if there's no empty space (no 0s)
    bool isFull = grid.every((row) => row.every((tile) => tile != 0));

    // 2. Check if no valid moves (no adjacent matching tiles)
    bool noMovesLeft = true;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        // Check right
        if (j < 3 && grid[i][j] == grid[i][j + 1]) return false;
        // Check down
        if (i < 3 && grid[i][j] == grid[i + 1][j]) return false;
      }
    }

    return isFull && noMovesLeft; // Game is over if full and no moves left
  }


  // Reset Game
  void _resetGame(Emitter<GameState> emit) {
    emit(GameInitial());
  }

  // Start Game
  void _startGame(Emitter<GameState> emit) {
    emit(GameRun(grid: _initGrid(), score: 0, previousGesture: -1));
  }

  List<List<int>> _copyGrid(List<List<int>> grid) {
    return List.generate(4, (i) => List.from(grid[i]));
  }
}

enum Direction { up, down, left, right }
