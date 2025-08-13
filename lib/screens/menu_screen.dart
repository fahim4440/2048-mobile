import 'package:flutter/material.dart';
import 'package:match2048/screens/mode_selection_screen.dart';
import 'package:match2048/widgets/tap_button.dart';

import 'high_score_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: kIsWeb ? const SizedBox() : BannerAdWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.indigo], // Gradient colors
            begin: Alignment.topLeft, // Start point
            end: Alignment.bottomRight, // End point
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: kToolbarHeight),
            Text(
              '2048 Game',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Expanded(
              child: SizedBox(
                height:
                    (MediaQuery.of(context).size.height - kToolbarHeight) * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TapButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModeSelectionScreen(),
                          ),
                        );
                      },
                      text: 'Select Mode',
                      color: Colors.green.shade600,
                      iconData: Icons.play_arrow_outlined,
                    ),
                    const SizedBox(height: 20),
                    TapButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HighScoreScreen(),
                          ),
                        );
                      },
                      text: 'High Scores',
                      color: Colors.blue.shade900,
                      iconData: Icons.gamepad,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
