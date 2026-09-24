import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../providers/quest_provider.dart';
import '../../models/quest_model.dart';
import '../../config/routes.dart';
import '../../widgets/quest_card.dart';
import '../../widgets/xp_bar.dart';
import '../../widgets/rank_badge.dart';
import '../../widgets/loading_shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/quest_dialogs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
            final double progress = playerProvider.levelProgress;
            final rank = playerProvider.currentRank;

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
                      _buildStatBadge('Shadows', '⚔️ ${user?.shadowArmy ?? 0}', const Color(0xFF7B2FFF)),
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 32),
                  
                  // Today's Progress Card
                  _buildGlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY',
                          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildProgressStat('Quests', '${questProvider.completedToday}/${questProvider.totalToday}', const Color(0xFF00D4FF)),
                            _buildProgressStat('Focus', '0h 0m', Colors.greenAccent),
                          ],
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 32),
                  
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
                    ],
                  )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Quest List
                  if (questProvider.isLoading)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)))
                  else if (questProvider.dailyQuests.isEmpty)
                    const Center(child: Text('No daily quests found.', style: TextStyle(color: Colors.white54)))
                  else
                    ...questProvider.dailyQuests.map((quest) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: QuestCard(
                          quest: quest,
                          onTap: () {
                            if (quest.status != QuestStatus.completed) {
                              Navigator.pushNamed(context, AppRoutes.focus, arguments: quest);
                            }
                          },
                          onComplete: () async {
                            if (quest.status != QuestStatus.completed && user != null) {
                              showQuestCompletionDialog(
                                context,
                                quest,
                                user.id,
                                questProvider,
                                playerProvider,
                              );
                            }
                          },
                        ),
                      ).animate().fade(duration: 400.ms).slideX(begin: 0.1);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.bold, fontSize: 16),
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
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.05),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.rajdhani(color: color, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
