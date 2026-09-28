import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';

class AchievementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// All possible achievements in the game
  static final List<AchievementModel> allAchievements = [
    // Quest Milestones
    const AchievementModel(
      id: 'first_blood', achievementKey: 'first_blood',
      title: 'First Blood', description: 'Complete your very first quest.',
      iconName: 'sword', xpReward: 50, requirement: 'Complete 1 quest',
    ),
    const AchievementModel(
      id: 'quest_hunter', achievementKey: 'quest_hunter',
      title: 'Quest Hunter', description: 'Complete 10 quests total.',
      iconName: 'target', xpReward: 100, requirement: 'Complete 10 quests',
    ),
    const AchievementModel(
      id: 'quest_slayer', achievementKey: 'quest_slayer',
      title: 'Quest Slayer', description: 'Complete 50 quests total.',
      iconName: 'fire', xpReward: 250, requirement: 'Complete 50 quests',
    ),
    const AchievementModel(
      id: 'quest_legend', achievementKey: 'quest_legend',
      title: 'Quest Legend', description: 'Complete 100 quests total.',
      iconName: 'crown', xpReward: 500, requirement: 'Complete 100 quests',
    ),

    // Streak Milestones
    const AchievementModel(
      id: 'consistency', achievementKey: 'consistency',
      title: 'Consistency', description: 'Maintain a 3-day streak.',
      iconName: 'streak', xpReward: 50, requirement: '3-day streak',
    ),
    const AchievementModel(
      id: 'unbreakable', achievementKey: 'unbreakable',
      title: 'Unbreakable', description: 'Maintain a 7-day streak.',
      iconName: 'shield', xpReward: 100, requirement: '7-day streak',
    ),
    const AchievementModel(
      id: 'iron_will', achievementKey: 'iron_will',
      title: 'Iron Will', description: 'Maintain a 14-day streak.',
      iconName: 'diamond', xpReward: 200, requirement: '14-day streak',
    ),
    const AchievementModel(
      id: 'unstoppable', achievementKey: 'unstoppable',
      title: 'Unstoppable', description: 'Maintain a 30-day streak.',
      iconName: 'lightning', xpReward: 500, requirement: '30-day streak',
    ),

    // XP & Level Milestones
    const AchievementModel(
      id: 'awakened', achievementKey: 'awakened',
      title: 'Awakened One', description: 'Reach Level 5.',
      iconName: 'star', xpReward: 100, requirement: 'Reach Level 5',
    ),
    const AchievementModel(
      id: 'shadow_initiate', achievementKey: 'shadow_initiate',
      title: 'Shadow Initiate', description: 'Reach Level 10.',
      iconName: 'moon', xpReward: 200, requirement: 'Reach Level 10',
    ),
    const AchievementModel(
      id: 'dungeon_master', achievementKey: 'dungeon_master',
      title: 'Dungeon Master', description: 'Reach Level 25.',
      iconName: 'castle', xpReward: 500, requirement: 'Reach Level 25',
    ),

    // Rank Milestones
    const AchievementModel(
      id: 'rank_d', achievementKey: 'rank_d',
      title: 'D-Rank Hunter', description: 'Achieve D-Rank.',
      iconName: 'rank', xpReward: 100, requirement: 'Reach D-Rank',
    ),
    const AchievementModel(
      id: 'rank_c', achievementKey: 'rank_c',
      title: 'C-Rank Hunter', description: 'Achieve C-Rank.',
      iconName: 'rank', xpReward: 200, requirement: 'Reach C-Rank',
    ),
    const AchievementModel(
      id: 'rank_b', achievementKey: 'rank_b',
      title: 'B-Rank Hunter', description: 'Achieve B-Rank.',
      iconName: 'rank', xpReward: 300, requirement: 'Reach B-Rank',
    ),
    const AchievementModel(
      id: 'rank_a', achievementKey: 'rank_a',
      title: 'A-Rank Hunter', description: 'Achieve A-Rank.',
      iconName: 'rank', xpReward: 500, requirement: 'Reach A-Rank',
    ),
    const AchievementModel(
      id: 'shadow_monarch', achievementKey: 'shadow_monarch',
      title: 'Shadow Monarch', description: 'Achieve the legendary S-Rank.',
      iconName: 'crown', xpReward: 1000, requirement: 'Reach S-Rank',
    ),

    // Focus Time
    const AchievementModel(
      id: 'focused_mind', achievementKey: 'focused_mind',
      title: 'Focused Mind', description: 'Accumulate 60 minutes of focus time.',
      iconName: 'timer', xpReward: 50, requirement: '60 min focus time',
    ),
    const AchievementModel(
      id: 'deep_focus', achievementKey: 'deep_focus',
      title: 'Deep Focus', description: 'Accumulate 5 hours of focus time.',
      iconName: 'brain', xpReward: 200, requirement: '5 hours focus time',
    ),

    // Guild
    const AchievementModel(
      id: 'guild_member', achievementKey: 'guild_member',
      title: 'Guild Member', description: 'Join or create a guild.',
      iconName: 'shield', xpReward: 50, requirement: 'Join a guild',
    ),

    // Shadow Army
    const AchievementModel(
      id: 'shadow_commander', achievementKey: 'shadow_commander',
      title: 'Shadow Commander', description: 'Build a shadow army of 10.',
      iconName: 'army', xpReward: 100, requirement: '10 shadows',
    ),
  ];

  /// Get the user's earned achievements from Firestore
  Future<Map<String, DateTime>> getEarnedAchievements(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId)
          .collection('achievements').doc('earned').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final Map<String, DateTime> earned = {};
        data.forEach((key, value) {
          if (value is Timestamp) {
            earned[key] = value.toDate();
          }
        });
        return earned;
      }
    } catch (e) {
      // First time - no achievements doc yet
    }
    return {};
  }

  /// Save a newly earned achievement to Firestore
  Future<void> unlockAchievement(String userId, String achievementKey) async {
    await _firestore.collection('users').doc(userId)
        .collection('achievements').doc('earned').set({
      achievementKey: Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// Check all achievements against current player stats
  /// Returns a list of newly unlocked achievement keys
  Future<List<String>> checkAndUnlockAchievements({
    required String userId,
    required int totalXP,
    required int level,
    required String rank,
    required int bestStreak,
    required int completedQuests,
    required int totalFocusMins,
    required int shadowArmy,
    required String? guildId,
  }) async {
    final earned = await getEarnedAchievements(userId);
    final List<String> newlyUnlocked = [];

    // Define unlock conditions for each achievement
    final Map<String, bool> conditions = {
      'first_blood': completedQuests >= 1,
      'quest_hunter': completedQuests >= 10,
      'quest_slayer': completedQuests >= 50,
      'quest_legend': completedQuests >= 100,
      'consistency': bestStreak >= 3,
      'unbreakable': bestStreak >= 7,
      'iron_will': bestStreak >= 14,
      'unstoppable': bestStreak >= 30,
      'awakened': level >= 5,
      'shadow_initiate': level >= 10,
      'dungeon_master': level >= 25,
      'rank_d': _rankIndex(rank) >= 1,
      'rank_c': _rankIndex(rank) >= 2,
      'rank_b': _rankIndex(rank) >= 3,
      'rank_a': _rankIndex(rank) >= 4,
      'shadow_monarch': _rankIndex(rank) >= 5,
      'focused_mind': totalFocusMins >= 60,
      'deep_focus': totalFocusMins >= 300,
      'guild_member': guildId != null,
      'shadow_commander': shadowArmy >= 10,
    };

    for (final entry in conditions.entries) {
      if (entry.value && !earned.containsKey(entry.key)) {
        await unlockAchievement(userId, entry.key);
        newlyUnlocked.add(entry.key);
      }
    }

    return newlyUnlocked;
  }

  /// Helper: map rank letter to index for comparison
  int _rankIndex(String rank) {
    const ranks = ['E', 'D', 'C', 'B', 'A', 'S'];
    return ranks.indexOf(rank);
  }

  /// Build the full achievement list with earned status merged in
  List<AchievementModel> buildAchievementList(Map<String, DateTime> earned) {
    return allAchievements.map((a) {
      if (earned.containsKey(a.achievementKey)) {
        return a.copyWith(isEarned: true, earnedAt: earned[a.achievementKey]);
      }
      return a;
    }).toList();
  }
}
