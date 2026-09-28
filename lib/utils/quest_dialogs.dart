import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quest_model.dart';
import '../providers/quest_provider.dart';
import '../providers/player_provider.dart';
import '../providers/achievement_provider.dart';
import '../config/constants.dart';

Future<void> showQuestCompletionDialog(
  BuildContext context,
  QuestModel quest,
  String userId,
  QuestProvider questProvider,
  PlayerProvider playerProvider,
) async {
  final TextEditingController timeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        title: Text(
          'QUEST COMPLETE',
          style: GoogleFonts.orbitron(
            color: AppColors.cyan,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
            shadows: [const Shadow(color: AppColors.cyan, blurRadius: 10)],
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How did you perform on\n"${quest.title}"?',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Time Spent (Minutes)',
                  hintText: 'e.g. 45',
                  hintStyle: TextStyle(color: Colors.white24),
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cyan)),
                  prefixIcon: Icon(Icons.timer, color: AppColors.cyan),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'What did you do / study?',
                  hintText: 'e.g. Completed 2 chapters of Physics',
                  hintStyle: TextStyle(color: Colors.white24),
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cyan)),
                  prefixIcon: Icon(Icons.edit_note, color: AppColors.cyan),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+${quest.xpReward} XP',
                      style: GoogleFonts.orbitron(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final int? timeSpent = int.tryParse(timeController.text);
              final String notes = notesController.text.trim();
              
              // Grab achievement provider before popping
              final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
              
              Navigator.pop(context);
              
              // 1. Complete the quest with notes
              await questProvider.completeQuest(
                userId,
                quest.id,
                timeSpentMins: timeSpent,
                notes: notes.isNotEmpty ? notes : null,
              );
              
              // 2. Award XP
              await playerProvider.addXP(
                userId: userId,
                difficulty: quest.difficulty,
                statType: quest.statType,
              );
              
              // 3. Update streak
              await playerProvider.updateStreak(userId);

              // 4. Check achievements after quest completion
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
              'CLAIM REWARD',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      );
    },
  );
}
