import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../services/achievement_service.dart';
import '../services/quest_service.dart';

class AchievementProvider extends ChangeNotifier {
  final AchievementService _achievementService = AchievementService();
  final QuestService _questService = QuestService();

  List<AchievementModel> _achievements = [];
  List<String> _recentlyUnlocked = [];
  bool _isLoading = false;
  int _totalFocusMins = 0;

  List<AchievementModel> get achievements => _achievements;
  List<AchievementModel> get earnedAchievements => _achievements.where((a) => a.isEarned).toList();
  List<AchievementModel> get lockedAchievements => _achievements.where((a) => !a.isEarned).toList();
  List<String> get recentlyUnlocked => _recentlyUnlocked;
  bool get isLoading => _isLoading;
  int get totalFocusMins => _totalFocusMins;

  /// Load achievements and merge with earned status
  Future<void> loadAchievements(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final earned = await _achievementService.getEarnedAchievements(userId);
      _achievements = _achievementService.buildAchievementList(earned);
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      _achievements = AchievementService.allAchievements;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check and unlock achievements based on current player stats
  /// Call this after XP gain, quest completion, streak update, etc.
  Future<void> checkAchievements({
    required String userId,
    required int totalXP,
    required int level,
    required String rank,
    required int bestStreak,
    required int shadowArmy,
    required String? guildId,
  }) async {
    try {
      // Get completed quests count
      final completedQuests = await _questService.getCompletedQuestsCount(userId);

      // Calculate total focus minutes from completed quests
      _totalFocusMins = await _getTotalFocusMinutes(userId);

      final newlyUnlocked = await _achievementService.checkAndUnlockAchievements(
        userId: userId,
        totalXP: totalXP,
        level: level,
        rank: rank,
        bestStreak: bestStreak,
        completedQuests: completedQuests,
        totalFocusMins: _totalFocusMins,
        shadowArmy: shadowArmy,
        guildId: guildId,
      );

      if (newlyUnlocked.isNotEmpty) {
        _recentlyUnlocked = newlyUnlocked;
        // Reload to update UI
        await loadAchievements(userId);
      }
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }

  /// Clear recently unlocked (after showing notification)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked = [];
    notifyListeners();
  }

  /// Calculate total focus minutes from all completed quests
  Future<int> _getTotalFocusMinutes(String userId) async {
    try {
      final snapshot = await _questService.getCompletedQuestsSnapshot(userId);
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['timeSpentMins'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
