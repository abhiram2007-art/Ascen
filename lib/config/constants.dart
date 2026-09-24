import 'package:flutter/material.dart';

// ─── Quest Types ───
enum QuestType { daily, main, side, habit, challenge }

extension QuestTypeExtension on QuestType {
  String get label {
    switch (this) {
      case QuestType.daily: return 'Daily';
      case QuestType.main: return 'Main';
      case QuestType.side: return 'Side';
      case QuestType.habit: return 'Habit';
      case QuestType.challenge: return 'Challenge';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestType.daily: return Icons.today;
      case QuestType.main: return Icons.flag;
      case QuestType.side: return Icons.explore;
      case QuestType.habit: return Icons.repeat;
      case QuestType.challenge: return Icons.local_fire_department;
    }
  }
}

// ─── Difficulty ───
enum QuestDifficulty { easy, medium, hard, major, challenge }

extension QuestDifficultyExtension on QuestDifficulty {
  int get xpReward {
    switch (this) {
      case QuestDifficulty.easy: return 25;
      case QuestDifficulty.medium: return 50;
      case QuestDifficulty.hard: return 100;
      case QuestDifficulty.major: return 200;
      case QuestDifficulty.challenge: return 500;
    }
  }

  String get label {
    switch (this) {
      case QuestDifficulty.easy: return 'Easy';
      case QuestDifficulty.medium: return 'Medium';
      case QuestDifficulty.hard: return 'Hard';
      case QuestDifficulty.major: return 'Major';
      case QuestDifficulty.challenge: return 'Challenge';
    }
  }

  Color get color {
    switch (this) {
      case QuestDifficulty.easy: return const Color(0xFF4CAF50);
      case QuestDifficulty.medium: return const Color(0xFF00D4FF);
      case QuestDifficulty.hard: return const Color(0xFFFF9800);
      case QuestDifficulty.major: return const Color(0xFF7B2FFF);
      case QuestDifficulty.challenge: return const Color(0xFFFF3333);
    }
  }
}

// ─── Stat Types ───
enum StatType { strength, intelligence, vitality, agility, perception }

extension StatTypeExtension on StatType {
  String get label {
    switch (this) {
      case StatType.strength: return 'Strength';
      case StatType.intelligence: return 'Intelligence';
      case StatType.vitality: return 'Vitality';
      case StatType.agility: return 'Agility';
      case StatType.perception: return 'Perception';
    }
  }

  IconData get icon {
    switch (this) {
      case StatType.strength: return Icons.fitness_center;
      case StatType.intelligence: return Icons.psychology;
      case StatType.vitality: return Icons.favorite;
      case StatType.agility: return Icons.speed;
      case StatType.perception: return Icons.visibility;
    }
  }
}

// ─── Rank System ───
class RankInfo {
  final String name;
  final String displayName;
  final int minLevel;
  final int maxLevel;
  final Color color;

  const RankInfo({
    required this.name,
    required this.displayName,
    required this.minLevel,
    required this.maxLevel,
    required this.color,
  });
}

class RankSystem {
  static const List<RankInfo> ranks = [
    RankInfo(name: 'E', displayName: 'E-Rank', minLevel: 1, maxLevel: 4, color: Color(0xFF888888)),
    RankInfo(name: 'D', displayName: 'D-Rank', minLevel: 5, maxLevel: 9, color: Color(0xFF00CC66)),
    RankInfo(name: 'C', displayName: 'C-Rank', minLevel: 10, maxLevel: 19, color: Color(0xFF0088FF)),
    RankInfo(name: 'B', displayName: 'B-Rank', minLevel: 20, maxLevel: 29, color: Color(0xFF7B2FFF)),
    RankInfo(name: 'A', displayName: 'A-Rank', minLevel: 30, maxLevel: 49, color: Color(0xFFFFD700)),
    RankInfo(name: 'S', displayName: 'S-Rank', minLevel: 50, maxLevel: 999, color: Color(0xFFFF3333)),
  ];

  static RankInfo getRankForLevel(int level) {
    for (final rank in ranks.reversed) {
      if (level >= rank.minLevel) return rank;
    }
    return ranks.first;
  }

  static Color getColorForRank(String rankName) {
    return ranks.firstWhere(
      (r) => r.name == rankName,
      orElse: () => ranks.first,
    ).color;
  }
}

// ─── XP System ───
class XPSystem {
  /// XP required to reach a given level from the previous level
  /// Formula: level * 100 + (level - 1) * 50
  static int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;
    return level * 100 + (level - 1) * 50;
  }

  /// Total XP required to reach a given level from level 1
  static int totalXPForLevel(int level) {
    int total = 0;
    for (int i = 2; i <= level; i++) {
      total += xpRequiredForLevel(i);
    }
    return total;
  }

  /// Calculate level from total XP
  static int levelFromTotalXP(int totalXP) {
    int level = 1;
    int xpAccumulated = 0;
    while (true) {
      int nextLevelXP = xpRequiredForLevel(level + 1);
      if (xpAccumulated + nextLevelXP > totalXP) break;
      xpAccumulated += nextLevelXP;
      level++;
    }
    return level;
  }

  /// XP progress within current level (0 to xpRequiredForLevel)
  static int currentLevelXP(int totalXP) {
    int level = levelFromTotalXP(totalXP);
    return totalXP - totalXPForLevel(level);
  }
}

// ─── Streak Bonuses ───
class StreakBonus {
  static const Map<int, int> bonuses = {
    3: 10,
    7: 25,
    14: 50,
    30: 100,
  };

  /// Get streak bonus XP for current streak day
  static int getBonusForStreak(int streakDay) {
    return bonuses[streakDay] ?? 0;
  }
}

// ─── Title System ───
class TitleSystem {
  static const Map<int, String> titles = {
    1: 'Newborn Player',
    5: 'Awakened One',
    10: 'Shadow Initiate',
    15: 'Dungeon Crawler',
    20: 'Ascendant',
    30: 'Shadow Commander',
    40: 'Monarch Aspirant',
    50: 'Shadow Monarch',
  };

  static String getTitleForLevel(int level) {
    String title = 'Newborn Player';
    for (final entry in titles.entries) {
      if (level >= entry.key) title = entry.value;
    }
    return title;
  }
}

class AppFonts {
  static const String orbitron = 'Orbitron';
  static const String rajdhani = 'Rajdhani';
  static const String inter = 'Inter';
}

// ─── App Colors (re-export for convenience) ───
class AppColors {
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color systemPanel = Color(0xFF12121A);
  static const Color surfaceLight = Color(0xFF1A1A2E);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color gold = Color(0xFFFFD700);
  static const Color purple = Color(0xFF7B2FFF);
  static const Color crimson = Color(0xFFFF3333);
  static const Color success = Color(0xFF00CC66);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF4444);

  // Rank colors
  static const Color rankE = Color(0xFF888888);
  static const Color rankD = Color(0xFF00CC66);
  static const Color rankC = Color(0xFF0088FF);
  static const Color rankB = Color(0xFF7B2FFF);
  static const Color rankA = Color(0xFFFFD700);
  static const Color rankS = Color(0xFFFF3333);
}

// ─── Daily Completion Bonus ───
const int dailyCompletionBonusXP = 25;
