import 'package:aa_teris/values/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager {
  static const String _highScoreKey = "high_score";
  static const String _isMutedKey = "is_muted";
  static const String _currentDifficultyKey = "current_difficulty";
  static const String _migrationCompletedKey = "migration_completed";

  static String _getHighScoreKeyForDifficulty(Difficulty difficulty) {
    return "${_highScoreKey}_${difficulty.name}";
  }

  static Future<void> setHighScore(int score, Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    int currentHighScore = await getHighScore(difficulty);
    if (score > currentHighScore) {
      await prefs.setInt(_getHighScoreKeyForDifficulty(difficulty), score);
    }
  }

  static Future<int> getHighScore(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getHighScoreKeyForDifficulty(difficulty)) ?? 0;
  }

  static Future<Map<Difficulty, int>> getAllHighScores() async {
    final result = <Difficulty, int>{};
    for (final difficulty in Difficulty.values) {
      result[difficulty] = await getHighScore(difficulty);
    }
    return result;
  }

  // Legacy method for backward compatibility
  static Future<int> getLegacyHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<void> migrateLegacyHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final migrationCompleted = prefs.getBool(_migrationCompletedKey) ?? false;

    if (!migrationCompleted) {
      final legacyHighScore = await getLegacyHighScore();
      if (legacyHighScore > 0) {
        // Migrate the legacy high score to medium difficulty
        await setHighScore(legacyHighScore, Difficulty.medium);
      }

      // Mark migration as completed
      await prefs.setBool(_migrationCompletedKey, true);
    }
  }

  static Future<void> setCurrentDifficulty(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentDifficultyKey, difficulty.name);
  }

  static Future<Difficulty> getCurrentDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    final difficultyName = prefs.getString(_currentDifficultyKey);
    return difficultyName != null
        ? Difficulty.values.firstWhere(
          (d) => d.name == difficultyName,
          orElse: () => Difficulty.medium,
        )
        : Difficulty.medium; // Default to medium
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
