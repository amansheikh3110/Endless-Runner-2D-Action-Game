import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _highScoreKey = 'high_score';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  static Future<bool> isNewHighScore(int score) async {
    final highScore = await getHighScore();
    return score > highScore;
  }
}

