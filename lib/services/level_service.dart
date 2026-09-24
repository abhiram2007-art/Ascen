import '../config/constants.dart';

class LevelService {
  /// Get current level from total XP
  static int getCurrentLevel(int totalXP) => XPSystem.levelFromTotalXP(totalXP);
  
  /// Get XP progress within current level
  static int getCurrentLevelXP(int totalXP) => XPSystem.currentLevelXP(totalXP);
  
  /// Get XP needed for next level
  static int getXPForNextLevel(int totalXP) {
    int currentLevel = getCurrentLevel(totalXP);
    return XPSystem.xpRequiredForLevel(currentLevel + 1);
  }
  
  /// Check if adding XP causes a level up, returns new level or null
  static int? checkLevelUp(int currentTotalXP, int xpToAdd) {
    int oldLevel = getCurrentLevel(currentTotalXP);
    int newLevel = getCurrentLevel(currentTotalXP + xpToAdd);
    if (newLevel > oldLevel) {
      return newLevel;
    }
    return null;
  }
  
  /// Get rank for a given level
  static RankInfo getRank(int level) => RankSystem.getRankForLevel(level);
  
  /// Check if level change causes rank promotion, returns new RankInfo or null
  static RankInfo? checkRankPromotion(int oldLevel, int newLevel) {
    RankInfo oldRank = getRank(oldLevel);
    RankInfo newRank = getRank(newLevel);
    if (newRank.name != oldRank.name) {
      return newRank;
    }
    return null;
  }
  
  /// Get title for level
  static String getTitle(int level) => TitleSystem.getTitleForLevel(level);
  
  /// Calculate progress percentage to next level (0.0 to 1.0)
  static double getLevelProgress(int totalXP) {
    int currentLevel = getCurrentLevel(totalXP);
    int nextLevelXP = XPSystem.xpRequiredForLevel(currentLevel + 1);
    if (nextLevelXP <= 0) return 1.0; // Max level or invalid handling
    int currentXP = getCurrentLevelXP(totalXP);
    return (currentXP / nextLevelXP).clamp(0.0, 1.0);
  }
}
