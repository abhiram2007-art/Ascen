import '../config/constants.dart';

class XPService {
  /// Calculate XP reward for completing a quest
  static int calculateQuestXP(QuestDifficulty difficulty) => difficulty.xpReward;
  
  /// Calculate streak bonus XP
  static int calculateStreakBonus(int currentStreak) {
    // Check StreakBonus.bonuses map for exact day matches
    return StreakBonus.getBonusForStreak(currentStreak);
  }
  
  /// Calculate daily completion bonus (all daily quests done)
  static int calculateDailyCompletionBonus(int completedDailyQuests, int totalDailyQuests) {
    if (totalDailyQuests > 0 && completedDailyQuests >= totalDailyQuests) {
      return dailyCompletionBonusXP; // 25 XP
    }
    return 0;
  }
  
  /// Total XP earned from completing a quest (base + streak + daily)
  static int calculateTotalXP({
    required QuestDifficulty difficulty,
    required int currentStreak,
    int completedDailyQuests = 0,
    int totalDailyQuests = 0,
  }) {
    int total = calculateQuestXP(difficulty);
    total += calculateStreakBonus(currentStreak);
    total += calculateDailyCompletionBonus(completedDailyQuests, totalDailyQuests);
    return total;
  }
}
