import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../config/constants.dart';
import '../../widgets/rank_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndCheckAchievements();
    });
  }

  void _loadAndCheckAchievements() {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    final player = Provider.of<PlayerProvider>(context, listen: false);
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);

    if (userId != null && player.user != null) {
      achievementProvider.loadAchievements(userId);
      achievementProvider.checkAchievements(
        userId: userId,
        totalXP: player.user!.totalXP,
        level: player.currentLevel,
        rank: player.currentRank.name,
        bestStreak: player.user!.bestStreak,
        shadowArmy: player.user!.shadowArmy,
        guildId: player.user!.guildId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PLAYER PROFILE',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.cyan),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer2<PlayerProvider, AchievementProvider>(
          builder: (context, playerProvider, achievementProvider, _) {
            final user = playerProvider.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final earned = achievementProvider.earnedAchievements;
            // Show up to 4 recent achievements
            final displayAchievements = earned.length > 4
                ? earned.sublist(earned.length - 4)
                : earned;

            return Column(
              children: [
                const SizedBox(height: 16),
                RankBadge(rank: user.rank, size: 'large'),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: GoogleFonts.orbitron(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.title,
                  style: GoogleFonts.rajdhani(fontSize: 16, color: AppColors.cyan, letterSpacing: 2),
                ),
                const SizedBox(height: 32),
                
                // Stat Cards
                Row(
                  children: [
                    Expanded(child: _buildProfileStat('Level', '${playerProvider.currentLevel}', AppColors.cyan)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildProfileStat('Total XP', '${user.totalXP}', AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildProfileStat('Best Streak', '🔥 ${user.bestStreak}', Colors.orange)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildProfileStat('Shadows', '⚔️ ${user.shadowArmy}', AppColors.purple)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.systemPanel,
                            side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.calendar_month, color: AppColors.cyan),
                          label: Text(
                            'HISTORY',
                            style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.systemPanel,
                            side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.bar_chart, color: AppColors.cyan),
                          label: Text(
                            'STATS',
                            style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/progress');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Achievements Header with VIEW ALL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACHIEVEMENTS',
                      style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/achievements');
                      },
                      child: Text(
                        'VIEW ALL (${earned.length}/${achievementProvider.achievements.length})',
                        style: GoogleFonts.rajdhani(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Show recent earned achievements or "No achievements yet"
                if (displayAchievements.isEmpty)
                  _buildAchievementRow('No Achievements Yet', 'Complete quests to unlock!', false)
                else
                  ...displayAchievements.map((a) =>
                    _buildAchievementRow(a.title, a.description, true),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAchievementRow(String title, String description, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isUnlocked ? AppColors.gold.withValues(alpha: 0.5) : Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            isUnlocked ? Icons.emoji_events : Icons.lock_outline,
            color: isUnlocked ? AppColors.gold : Colors.white38,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: isUnlocked ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: isUnlocked ? Colors.white70 : Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
