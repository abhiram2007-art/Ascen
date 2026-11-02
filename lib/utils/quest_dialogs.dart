import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quest_model.dart';
import '../providers/quest_provider.dart';
import '../providers/player_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/notification_service.dart';
import '../config/constants.dart';

Future<void> showQuestCompletionDialog(
  BuildContext context,
  QuestModel quest,
  String userId,
  QuestProvider questProvider,
  PlayerProvider playerProvider,
) async {
  final TextEditingController timeController = TextEditingController(text: '30');
  int selectedMinutes = 30;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cyan, width: 1.5),
            ),
            title: Column(
              children: [
                Text(
                  'COMPLETE QUEST',
                  style: GoogleFonts.orbitron(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2,
                    shadows: [const Shadow(color: AppColors.cyan, blurRadius: 10)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  quest.title,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'How much time did you spend on this quest?',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick selection chips
                  Wrap(
                    spacing: 8,
                    children: [15, 30, 45, 60].map((mins) {
                      final isSelected = selectedMinutes == mins;
                      return ChoiceChip(
                        label: Text('$mins min'),
                        selected: isSelected,
                        selectedColor: AppColors.cyan,
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              selectedMinutes = mins;
                              timeController.text = mins.toString();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Numeric text input
                  TextField(
                    controller: timeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (val) {
                      setState(() {
                        selectedMinutes = int.tryParse(val) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Time Spent (Minutes)',
                      labelStyle: const TextStyle(color: Colors.white60),
                      suffixText: 'mins',
                      suffixStyle: const TextStyle(color: AppColors.cyan),
                      prefixIcon: const Icon(Icons.timer, color: AppColors.cyan),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.cyan),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reward banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '+${quest.xpReward} EXP REWARD',
                          style: GoogleFonts.orbitron(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final int timeSpent = int.tryParse(timeController.text.trim()) ?? selectedMinutes;
                  final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);

                  Navigator.pop(dialogContext);

                  // 1. Mark complete in Firestore & Provider
                  await questProvider.completeQuest(
                    userId,
                    quest.id,
                    timeSpentMins: timeSpent > 0 ? timeSpent : null,
                  );

                  // 2. Add XP to Total XP
                  final int earnedXP = await playerProvider.addXP(
                    userId: userId,
                    difficulty: quest.difficulty,
                    statType: quest.statType,
                    xpReward: quest.xpReward,
                  );

                  // 3. Update streak
                  await playerProvider.updateStreak(userId);

                  // 4. Show success confirmation banner
                  if (context.mounted) {
                    final currentTotal = playerProvider.user?.totalXP ?? 0;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                        ),
                        content: Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.gold),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '+$earnedXP EXP ADDED! Total: $currentTotal EXP',
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }

                  // 5. Milestone & completion alerts
                  final currentStreak = playerProvider.user?.streak ?? 0;
                  if (const [3, 7, 14, 30].contains(currentStreak)) {
                    NotificationService().showSystemAlert(
                      title: 'STREAK MILESTONE REACHED! 🔥',
                      body: 'Impressive, Player. You have maintained a $currentStreak-day streak.',
                    );
                  }

                  if (questProvider.totalToday > 0 && questProvider.completedToday == questProvider.totalToday) {
                    NotificationService().showSystemAlert(
                      title: 'ALL DAILY OBJECTIVES CLEARED! ⚔️',
                      body: 'All daily quests for today are complete. Rest well, Hunter.',
                    );
                  }

                  // 6. Check achievements
                  if (playerProvider.user != null) {
                    await achievementProvider.checkAchievements(
                      userId: userId,
                      totalXP: playerProvider.user!.totalXP,
                      level: playerProvider.currentLevel,
                      rank: playerProvider.currentRank.name,
                      bestStreak: playerProvider.user!.bestStreak,
                      shadowArmy: playerProvider.user!.shadowArmy,
                      guildId: playerProvider.user!.guildId,
                    );
                  }
                },
                child: Text(
                  'CONFIRM & CLAIM',
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
