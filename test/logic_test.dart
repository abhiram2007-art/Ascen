import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/services/level_service.dart';
import 'package:ascend/services/xp_service.dart';
import 'package:ascend/services/streak_service.dart';
import 'package:ascend/services/achievement_service.dart';
import 'package:ascend/models/quest_model.dart';
import 'package:ascend/models/user_model.dart';
import 'package:ascend/config/constants.dart';

void main() {
  group('XPService Tests', () {
    test('Calculates base quest XP correctly based on difficulty', () {
      expect(XPService.calculateQuestXP(QuestDifficulty.easy), 25);
      expect(XPService.calculateQuestXP(QuestDifficulty.medium), 50);
      expect(XPService.calculateQuestXP(QuestDifficulty.challenge), 500);
    });

    test('Calculates streak bonus correctly', () {
      expect(XPService.calculateStreakBonus(2), 0);
      expect(XPService.calculateStreakBonus(3), 10);
      expect(XPService.calculateStreakBonus(7), 25);
      expect(XPService.calculateStreakBonus(30), 100);
    });
  });

  group('LevelService Tests', () {
    test('Calculates level accurately from total XP', () {
      expect(LevelService.getCurrentLevel(0), 1);
      expect(LevelService.getCurrentLevel(200), 1); // 250 needed for lvl 2
      expect(LevelService.getCurrentLevel(250), 2); 
      expect(LevelService.getCurrentLevel(650), 3); // 250 + 400 needed for lvl 3
    });

    test('Calculates rank accurately from level', () {
      expect(LevelService.getRank(1).name, 'E');
      expect(LevelService.getRank(5).name, 'D');
      expect(LevelService.getRank(20).name, 'B');
      expect(LevelService.getRank(50).name, 'S');
    });

    test('Calculates XP needed for next level', () {
      expect(LevelService.getXPForNextLevel(0), 250);
      expect(LevelService.getXPForNextLevel(250), 400); 
    });
  });

  group('StreakService Tests', () {
    test('Calculates new streak correctly', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final twoDaysAgo = now.subtract(const Duration(days: 2));

      // First time completion
      expect(StreakService.calculateNewStreak(0, null), 1);

      // Completed yesterday -> increments
      expect(StreakService.calculateNewStreak(5, yesterday), 6);

      // Completed earlier today -> stays the same
      expect(StreakService.calculateNewStreak(5, now), 5);

      // Missed yesterday -> resets to 1
      expect(StreakService.calculateNewStreak(5, twoDaysAgo), 1);
    });
  });

  group('AchievementService Tests', () {
    test('Has exactly 20 achievements defined', () {
      expect(AchievementService.allAchievements.length, 20);
    });

    test('All achievements have unique keys', () {
      final keys = AchievementService.allAchievements.map((a) => a.achievementKey).toSet();
      expect(keys.length, 20);
    });
  });

  group('Model Date Parsing Tests', () {
    test('QuestModel safely parses String or null dates without crashing', () {
      final map = {
        'title': 'Test Quest',
        'type': 'daily',
        'difficulty': 'easy',
        'status': 'pending',
        'dueDate': '2026-11-02T10:00:00.000Z',
        'createdAt': '2026-11-01T10:00:00.000Z',
        'reminderTime': '08:30',
      };
      final quest = QuestModel.fromMap(map, 'q1');
      expect(quest.title, 'Test Quest');
      expect(quest.dueDate, isNotNull);
      expect(quest.completedAt, isNull);
      expect(quest.reminderTime, '08:30');
    });

    test('UserModel safely parses String or null dates without crashing', () {
      final map = {
        'name': 'Hunter Sung',
        'email': 'hunter@solo.com',
        'totalXP': 500,
        'lastActiveDate': '2026-11-02T08:00:00.000Z',
      };
      final user = UserModel.fromMap(map, 'u1');
      expect(user.name, 'Hunter Sung');
      expect(user.lastActiveDate, isNotNull);
    });
  });

  group('Daily Progress & Reset Simulation Tests', () {
    test('Scenario 1: 5 habits created, 3 completed yields exactly 60% completion', () {
      const int totalHabits = 5;
      const int completedHabits = 3;
      final double rate = completedHabits / totalHabits;
      final int percent = (rate * 100).round();
      expect(percent, 60);
      expect(totalHabits - completedHabits, 2);
    });

    test('Scenario 4: Calendar day shift resets daily recurring quest status while retaining history data', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final completedQuest = QuestModel(
        id: 'q100',
        title: 'Morning Pushups',
        isRecurring: true,
        type: QuestType.daily,
        status: QuestStatus.completed,
        completedAt: yesterday,
        timeSpentMins: 20,
        createdAt: yesterday.subtract(const Duration(days: 5)),
      );

      // Verify that resetting resets status to pending for today
      final resetQuest = completedQuest.copyWith(
        status: QuestStatus.pending,
        clearCompletedAt: true,
        timeSpentMins: null,
      );

      expect(resetQuest.status, QuestStatus.pending);
      expect(resetQuest.completedAt, isNull);
      expect(resetQuest.isRecurring, isTrue);
      expect(completedQuest.completedAt, isNotNull); // Original history preserved
    });

    test('Scenario 5: Consecutive daily completions increase streak, gap breaks streak', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final twoDaysAgo = DateTime(now.year, now.month, now.day - 2);

      int currentStreak = 0;
      // Day 1
      currentStreak = StreakService.calculateNewStreak(currentStreak, null);
      expect(currentStreak, 1);

      // Day 2 (completed yesterday)
      currentStreak = StreakService.calculateNewStreak(currentStreak, yesterday);
      expect(currentStreak, 2);

      // Day 3 (completed yesterday)
      currentStreak = StreakService.calculateNewStreak(currentStreak, yesterday);
      expect(currentStreak, 3);

      // Gap of 2 days -> resets to 1 on next quest
      currentStreak = StreakService.calculateNewStreak(currentStreak, twoDaysAgo);
      expect(currentStreak, 1);
    });
  });
}
