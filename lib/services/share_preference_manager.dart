import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static const String _highScoreKey = "high_score";
  static const String _isMutedKey = "is_muted";

  static Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    int currentHighScore = await getHighScore();
    if (score > currentHighScore) {
      await prefs.setInt(_highScoreKey, score);
    }
  }

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<void> setMuted(bool isMuted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isMutedKey, isMuted);
  }

  static Future<bool> getMuted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isMutedKey) ?? false; // Default to unmuted
  }
}
