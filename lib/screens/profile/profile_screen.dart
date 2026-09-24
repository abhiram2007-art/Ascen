import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/player_provider.dart';
import '../../config/constants.dart';
import '../../widgets/rank_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
        child: Consumer<PlayerProvider>(
          builder: (context, playerProvider, _) {
            final user = playerProvider.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

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
                    Expanded(child: _buildProfileStat('Level', '${user.level}', AppColors.cyan)),
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.systemPanel,
                      side: BorderSide(color: AppColors.cyan.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.calendar_month, color: AppColors.cyan),
                    label: Text(
                      'VIEW QUEST HISTORY',
                      style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/history');
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ACHIEVEMENTS',
                    style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAchievementRow('First Blood', 'Completed your first daily quest.', true),
                _buildAchievementRow('Consistency', 'Maintained a 3-day streak.', user.bestStreak >= 3),
                _buildAchievementRow('Unbreakable', 'Maintained a 7-day streak.', user.bestStreak >= 7),
                _buildAchievementRow('Shadow Monarch', 'Reached S-Rank.', user.rank == 'S'),
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
