import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:match2048/screens/menu_screen.dart';
import 'package:match2048/services/high_score_manager.dart';
import 'package:match2048/widgets/tap_button.dart';
import 'package:match2048/widgets/tile.dart';
import '../blocs/game_bloc.dart';
import '../widgets/interstitial_ad.dart';

class GameScreen extends StatefulWidget {
  final InterstitialAdManager interstitialAdManager;
  const GameScreen({super.key, required this.interstitialAdManager});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  HighScoreManager manager = HighScoreManager();
  final double swipeSensitivity = 0.6;
  bool isSwipeHandled = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameOverState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Game Over"),
                content: Text("Your final score is: ${state.score}"),
                actions: <TextButton>[
                  TextButton(
                    child: Text("Go to Main Menu"),
                    onPressed: () async {
                      // Save score and go back to the main menu
                      widget.interstitialAdManager.showInterstitialAd(context, () async {
                        // After the ad is shown or failed, save the score and navigate
                        await manager.addNewScore(state.score);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    },
                  ),
                ],
              );
            },
          );
        }
      },
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
                        color: Colors.greenAccent
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (isSwipeHandled) return;
                      if (details.primaryDelta!.abs() > swipeSensitivity) {
                        if (details.primaryDelta! < 0) {
                          context.read<GameBloc>().add(SwipeUpEvent());
                        } else if (details.primaryDelta! > 0) {
                          context.read<GameBloc>().add(SwipeDownEvent());
                        }
                        isSwipeHandled = true;
                      }
                    },
                    onVerticalDragEnd: (_) {
                      isSwipeHandled = false;
                    },
                    onHorizontalDragUpdate: (details) {
                      if (isSwipeHandled) return;
                      if (details.primaryDelta!.abs() > swipeSensitivity) {
                        if (details.primaryDelta! < 0) {
                          context.read<GameBloc>().add(SwipeLeftEvent());
                        } else if (details.primaryDelta! > 0) {
                          context.read<GameBloc>().add(SwipeRightEvent());
                        }
                        isSwipeHandled = true;
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      isSwipeHandled = false;
                    },
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: 16,
                      // 4x4 grid = 16 tiles
                      itemBuilder: (context, index) {
                        int row = index ~/ 4;
                        int col = index % 4;
                        int value = state.grid[row][col];

                        return Tile(value: value);
                      },
                    ),
                  ),
                  SizedBox(height: 20,),
                  TapButton(
                    onPressed: () async {
                      widget.interstitialAdManager.showInterstitialAd(context, () async {
                        // After the ad is shown or failed, save the score and navigate
                        await manager.addNewScore(state.score);
                        context.read<GameBloc>().add(ResetGameEvent());
                      });
                    },
                    text: 'Back to Main Menu',
                    color: Colors.redAccent.shade400,
                    iconData: Icons.menu_open,
                  ),
                ],
              ),
            );
          }
          return MenuScreen();
        },
      ),
    );
  }
}
