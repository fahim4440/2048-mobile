import 'package:shared_preferences/shared_preferences.dart';

class HighScoreManager {
  static const String _key = 'high_scores';

  // Save scores
  Future<void> saveScores(List<int> scores) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, scores.map((score) => score.toString()).toList());
  }

  // Load scores
  Future<List<int>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? scoreList = prefs.getStringList(_key);
    if (scoreList != null) {
      return scoreList.map((score) => int.parse(score)).toList();
    } else {
      return [];
    }
  }

  // Add new score and keep top 5
  Future<void> addNewScore(int score) async {
    List<int> scores = await loadScores();
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a)); // Sort in descending order
    if (scores.length > 5) scores.removeLast(); // Keep only top 5
    await saveScores(scores);
  }
}