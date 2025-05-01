import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:match2048/widgets/tap_button.dart';

import '../blocs/game_bloc.dart';
import 'high_score_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height - kToolbarHeight) * 0.7,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TapButton(
            onPressed: () {
              context.read<GameBloc>().add(GameStartEvent());
            },
            text: 'Start Game',
            color: Colors.green.shade600,
            iconData: Icons.play_arrow_outlined,
          ),
          SizedBox(height: 20,),
          TapButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => HighScoreScreen()
              ));
            },
            text: 'High Scores',
            color: Colors.blue.shade900,
            iconData: Icons.gamepad,
          ),
        ],
      ),
    );
  }
}
