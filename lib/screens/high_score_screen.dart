import 'package:flutter/material.dart';

import '../services/high_score_manager.dart';

class HighScoreScreen extends StatelessWidget {
  const HighScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    HighScoreManager highScoreManager = HighScoreManager();
    return Scaffold(
      // bottomNavigationBar: BannerAdWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.lightBlueAccent, Colors.blue.shade900],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: FutureBuilder<List<int>>(
          future: highScoreManager.loadScores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              List<int>? highScores = snapshot.data ?? [];
              return Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, color: Colors.white,),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        'Top 5 Scores',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  highScores.isNotEmpty ? ListView.builder(
                    padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
                    shrinkWrap: true,
                    itemCount: highScores.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          'Score ${index + 1}: ${highScores[index]}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      );
                    },
                  ) : Center(child: Text('There is no high scores'),),
                ],
              );
            } else {
              return CircularProgressIndicator(); // Show loading while fetching
            }
          },
        ),
      ),
    );
  }
}
