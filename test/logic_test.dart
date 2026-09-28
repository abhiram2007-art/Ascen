import 'package:flutter_test/flutter_test.dart';
import 'package:ascend/services/level_service.dart';
import 'package:ascend/services/xp_service.dart';
import 'package:ascend/services/streak_service.dart';
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
}
