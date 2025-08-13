import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/game_bloc.dart';
import '../models/game_mode.dart';
import '../widgets/tap_button.dart';
import 'game_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  ModeSelectionScreen({super.key});

  // final InterstitialAdManager _interstitialAdManager = InterstitialAdManager();

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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500, maxHeight: MediaQuery.of(context).size.height - kToolbarHeight),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - kToolbarHeight,
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Select Game Mode',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: GameMode.values.length,
                      itemBuilder: (context, index) {
                        final mode = GameMode.values[index];
                        // Define a list of colors
                        final colors = [Colors.orange, Colors.blue, Colors.green];
                        return SizedBox(
                          child: Card(
                            color: colors[index % colors.length], // Assign color based on index
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BlocProvider(
                                          create:
                                              (context) => GameBloc(gameMode: mode)
                                                ..add(GameStartEvent(gameMode: mode)),
                                          child: GameScreen(),
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mode.displayName,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      mode.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TapButton(
                      onPressed: () => Navigator.pop(context),
                      text: 'Back',
                      color: Colors.red,
                      iconData: Icons.arrow_back,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
