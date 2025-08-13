import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:match2048/screens/menu_screen.dart';
import 'package:match2048/services/high_score_manager.dart';
import 'package:match2048/widgets/tap_button.dart';
import 'package:match2048/widgets/animated_tile.dart';
import '../blocs/game_bloc.dart';
import '../models/game_mode.dart';

class GameScreen extends StatefulWidget {
  // final InterstitialAdManager interstitialAdManager;
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  HighScoreManager manager = HighScoreManager();
  Offset? dragStartPos;
  Offset? dragEndPos;

  @override
  void initState() {
    // context.read<GameBloc>().add(GameStartEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.indigo], // Gradient colors
            begin: Alignment.topLeft, // Start point
            end: Alignment.bottomRight, // End point
          ),
        ),
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight,),
            BlocListener<GameBloc, GameState>(
              listener: (context, state) {
                if (state is GameOverState) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.indigoAccent,
                        title: Text("Game Over", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),),
                        content: Text("Your final score is: ${state.score}", style: TextStyle(color: Colors.white),),
                        actions: <TextButton>[
                          TextButton(
                            child: Text("Go to Main Menu", style: TextStyle(color: Colors.white),),
                            onPressed: () async {
                              // Save score and go back to the main menu
                              if (kIsWeb) {
                                await manager.addNewScore(state.score);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                // widget.interstitialAdManager.showInterstitialAd(
                                //   context,
                                //   () async {
                                //     // After the ad is shown or failed, save the score and navigate
                                //     await manager.addNewScore(state.score);
                                //     Navigator.pop(context);
                                //     Navigator.pop(context);
                                //   },
                                // );
                                await manager.addNewScore(state.score);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: BlocBuilder<GameBloc, GameState>(
                  builder: (context, state) {
                    if (state is GameRun) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'Score: ${state.score}',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildModeInfo(state),
                            SizedBox(height: 20),
                            GestureDetector(
                              onPanStart: (details) {
                                print('--- Pan Start ---');
                                dragStartPos = details.globalPosition;
                                print('Start Position: $dragStartPos');
                              },
                              onPanUpdate: (details) {
                                dragEndPos = details.globalPosition;
                                // print('Updating End Position: $dragEndPos');
                              },
                              onPanEnd: (details) {
                                print('--- Pan End ---');
                                if (dragStartPos == null || dragEndPos == null) {
                                  print('Error: Start or End position is null.');
                                  return;
                                }
                
                                final dx = dragEndPos!.dx - dragStartPos!.dx;
                                final dy = dragEndPos!.dy - dragStartPos!.dy;
                                const minSwipeDistance = 40.0;
                
                                print('dx: $dx, dy: $dy');
                                print('Swipe Distance Horizontal: ${dx.abs()}');
                                print('Swipe Distance Vertical: ${dy.abs()}');
                
                
                                if (dx.abs() > dy.abs()) {
                                  print('Decision: Horizontal Swipe');
                                  if (dx.abs() > minSwipeDistance) {
                                    if (dx > 0) {
                                      print('Action: Swipe Right');
                                      context.read<GameBloc>().add(SwipeRightEvent());
                                    } else {
                                      print('Action: Swipe Left');
                                      context.read<GameBloc>().add(SwipeLeftEvent());
                                    }
                                  } else {
                                    print('Result: Swipe distance too short.');
                                  }
                                } else {
                                  print('Decision: Vertical Swipe');
                                  if (dy.abs() > minSwipeDistance) {
                                    if (dy > 0) {
                                      print('Action: Swipe Down');
                                      context.read<GameBloc>().add(SwipeDownEvent());
                                    } else {
                                      print('Action: Swipe Up');
                                      context.read<GameBloc>().add(SwipeUpEvent());
                                    }
                                  } else {
                                    print('Result: Swipe distance too short.');
                                  }
                                }
                                dragStartPos = null;
                                dragEndPos = null;
                                print('--- Resetting Positions ---');
                              },
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final tileSize =
                                        (constraints.maxWidth - 50) /
                                        4; // 50 = total spacing (5 * 10)
                                    final spacing = 10.0;
                        
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[400]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Background grid
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.all(10),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 4,
                                                  crossAxisSpacing: spacing,
                                                  mainAxisSpacing: spacing,
                                                ),
                                            itemCount: 16,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(
                                                    8,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          // Animated tiles
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Stack(
                                              children:
                                                  state.tiles.map((tile) {
                                                    return AnimatedTile(
                                                      key: ValueKey(tile.id),
                                                      tile: tile,
                                                      tileSize: tileSize,
                                                      spacing: spacing,
                                                    );
                                                  }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            TapButton(
                              onPressed: () async {
                                if (kIsWeb) {
                                  await manager.addNewScore(state.score);
                                  // context.read<GameBloc>().add(ResetGameEvent());
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MenuScreen(),
                                    ),
                                  );
                                } else {
                                  // widget.interstitialAdManager.showInterstitialAd(
                                  //   context,
                                  //   () async {
                                  //     // After the ad is shown or failed, save the score and navigate
                                  //     await manager.addNewScore(state.score);
                                  //     context.read<GameBloc>().add(ResetGameEvent());
                                  //   },
                                  // );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MenuScreen(),
                                    ),
                                  );
                                }
                              },
                              text: 'Back to Main Menu',
                              color: Colors.redAccent.shade400,
                              iconData: Icons.menu_open,
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeInfo(GameRun state) {
    switch (state.gameMode) {
      case GameMode.timeAttack:
        final minutes = (state.timeLeft! ~/ 60);
        final seconds = (state.timeLeft! % 60).toString().padLeft(2, '0');
        return Text(
          'Time: $minutes:$seconds',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      case GameMode.moveLimit:
        return Text(
          'Moves Left: ${state.movesLeft}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
