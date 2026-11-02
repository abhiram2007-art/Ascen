import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../providers/quest_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/quest_model.dart';
import '../../config/routes.dart';
import '../../widgets/quest_card.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/rank_badge.dart';
import '../../widgets/loading_shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/quest_dialogs.dart';
import '../add_quest/add_quest_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _confirmDelete(BuildContext context, String userId, QuestModel quest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('DELETE QUEST', style: GoogleFonts.orbitron(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text('Delete "${quest.title}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<QuestProvider>(context, listen: false).deleteQuest(userId, quest.id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Consumer2<PlayerProvider, QuestProvider>(
          builder: (context, playerProvider, questProvider, child) {
            if (playerProvider.isLoading) {
              return const LoadingShimmer(width: 200, height: 200);
            }

            final user = playerProvider.user;
            final String greetingName = user?.name ?? 'Player';
            final int level = playerProvider.currentLevel;
            final int currentXP = playerProvider.currentLevelXP;
            final int xpToNext = playerProvider.xpToNextLevel;
            final rank = playerProvider.currentRank;

            final completedTodayQuests = questProvider.completedQuests.where((q) {
              if (q.completedAt == null) return false;
              final now = DateTime.now();
              return q.completedAt!.year == now.year && q.completedAt!.month == now.month && q.completedAt!.day == now.day;
            }).toList();
            
            int totalFocusMins = 0;
            for (var quest in completedTodayQuests) {
              totalFocusMins += quest.timeSpentMins ?? 0;
            }
            final focusHours = totalFocusMins ~/ 60;
            final focusMins = totalFocusMins % 60;
            final focusText = '${focusHours}h ${focusMins}m';

            final int percent = questProvider.todayCompletionPercent;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Player Header
                  Text(
                    '${_getGreeting()}, $greetingName',
                    style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18),
                  )
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Level $level',
                    style: GoogleFonts.orbitron(
                      color: const Color(0xFF00D4FF),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(color: Color(0xFF00D4FF), blurRadius: 15),
                      ],
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: Colors.white)
                  .then()
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),
                  
                  const SizedBox(height: 12),
                  
                  XPBar(
                    currentXP: currentXP,
                    requiredXP: xpToNext,
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL EXP: ${user?.totalXP ?? 0} EXP',
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'TO NEXT LEVEL: ${(xpToNext - currentXP).clamp(0, 99999)} XP',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Rank Badge
                      Column(
                        children: [
                          RankBadge(rank: rank.name, size: 'large')
                              .animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 2000.ms, color: Colors.white30),
                          const SizedBox(height: 4),
                          Text('Rank', style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                      _buildStatBadge('Streak', '🔥 ${user?.streak ?? 0}', Colors.orange),
                      _buildStatBadge('Best', '⚡ ${user?.bestStreak ?? 0}', const Color(0xFFFFD700)),
                      _buildStatBadge('Shadows', '⚔️ ${user?.shadowArmy ?? 0}', const Color(0xFF7B2FFF)),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 28),
                  
                  // Today's Progress Card with Percentage & Breakdown
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TODAY\'S OBJECTIVES',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D4FF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '$percent% CLEAR',
                                style: GoogleFonts.orbitron(
                                  color: const Color(0xFF00D4FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: questProvider.todayCompletionRate,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percent == 100 ? Colors.greenAccent : const Color(0xFF00D4FF),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildProgressStat('Completed', '${questProvider.completedToday}', Colors.greenAccent),
                            _buildProgressStat('Remaining', '${questProvider.remainingToday}', Colors.orangeAccent),
                            _buildProgressStat('Focus Time', focusText, const Color(0xFF00D4FF)),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 28),
                  
                  // Daily Quests Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAILY QUESTS',
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFF00D4FF),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          shadows: [
                            const Shadow(color: Color(0xFF00D4FF), blurRadius: 10),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.quests),
                        child: Text(
                          'VIEW ALL (${questProvider.allQuests.length})',
                          style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms),
                  
                  const SizedBox(height: 12),
                  
                  // Quest List
                  if (questProvider.isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
                  else if (questProvider.dailyQuests.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.assignment_turned_in_outlined, color: Colors.white38, size: 36),
                          const SizedBox(height: 8),
                          const Text(
                            'No daily quests scheduled for today.\nTap + below to create a daily quest.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ...questProvider.dailyQuests.map((quest) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: QuestCard(
                          quest: quest,
                          onTap: () {
                            if (quest.status != QuestStatus.completed) {
                              Navigator.pushNamed(context, AppRoutes.focus, arguments: quest);
                            }
                          },
                          onComplete: () async {
                            final authUser = Provider.of<AuthProvider>(context, listen: false).user;
                            final targetUserId = user?.id ?? authUser?.uid;
                            if (quest.status != QuestStatus.completed && targetUserId != null) {
                              showQuestCompletionDialog(
                                context,
                                quest,
                                targetUserId,
                                questProvider,
                                playerProvider,
                              );
                            }
                          },
                          onUncomplete: () async {
                            final authUser = Provider.of<AuthProvider>(context, listen: false).user;
                            final targetUserId = user?.id ?? authUser?.uid;
                            if (targetUserId != null) {
                              await questProvider.uncompleteQuest(targetUserId, quest.id);
                            }
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddQuestScreen(initialQuest: quest),
                              ),
                            );
                          },
                          onDelete: () {
                            final authUser = Provider.of<AuthProvider>(context, listen: false).user;
                            final targetUserId = user?.id ?? authUser?.uid;
                            if (targetUserId != null) {
                              _confirmDelete(context, targetUserId, quest);
                            }
                          },
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addQuest);
        },
        backgroundColor: const Color(0xFF0A0A0F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: Color(0xFF00D4FF)),
        ),
        child: const Icon(Icons.add, color: Color(0xFF00D4FF)),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: const Color(0xFF00D4FF).withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
