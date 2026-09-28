import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../models/achievement_model.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      if (userId != null) {
        Provider.of<AchievementProvider>(context, listen: false).loadAchievements(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ACHIEVEMENTS',
          style: GoogleFonts.orbitron(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.cyan),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
          }

          final earned = provider.earnedAchievements;
          final locked = provider.lockedAchievements;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(earned.length, provider.achievements.length),
                const SizedBox(height: 24),

                // Earned Section
                if (earned.isNotEmpty) ...[
                  Text(
                    'UNLOCKED (${earned.length})',
                    style: GoogleFonts.orbitron(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...earned.map((a) => _buildAchievementCard(a)),
                  const SizedBox(height: 24),
                ],

                // Locked Section
                Text(
                  'LOCKED (${locked.length})',
                  style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...locked.map((a) => _buildAchievementCard(a)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(int earned, int total) {
    final progress = total > 0 ? earned / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.systemPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withValues(alpha: 0.1), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HUNTER PROGRESS',
                style: GoogleFonts.orbitron(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                '$earned / $total',
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(AchievementModel achievement) {
    final isEarned = achievement.isEarned;
    final icon = _getIconForName(achievement.iconName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.systemPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEarned ? AppColors.gold.withValues(alpha: 0.5) : Colors.white12,
        ),
        boxShadow: isEarned
            ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.1), blurRadius: 8)]
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned
                  ? AppColors.gold.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isEarned ? AppColors.gold : Colors.white24,
                width: 2,
              ),
            ),
            child: Icon(
              isEarned ? icon : Icons.lock_outline,
              color: isEarned ? AppColors.gold : Colors.white38,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.orbitron(
                    color: isEarned ? Colors.white : Colors.white38,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: isEarned ? Colors.white70 : Colors.white24,
                    fontSize: 12,
                  ),
                ),
                if (isEarned && achievement.earnedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Earned ${_formatDate(achievement.earnedAt!)}',
                      style: TextStyle(
                        color: AppColors.gold.withValues(alpha: 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // XP Reward
          Column(
            children: [
              Text(
                '+${achievement.xpReward}',
                style: GoogleFonts.orbitron(
                  color: isEarned ? AppColors.gold : Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'XP',
                style: TextStyle(
                  color: isEarned ? AppColors.gold.withValues(alpha: 0.7) : Colors.white24,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForName(String name) {
    switch (name) {
      case 'sword': return Icons.gavel;
      case 'target': return Icons.track_changes;
      case 'fire': return Icons.local_fire_department;
      case 'crown': return Icons.workspace_premium;
      case 'streak': return Icons.bolt;
      case 'shield': return Icons.shield;
      case 'diamond': return Icons.diamond;
      case 'lightning': return Icons.flash_on;
      case 'star': return Icons.star;
      case 'moon': return Icons.nightlight_round;
      case 'castle': return Icons.castle;
      case 'rank': return Icons.military_tech;
      case 'timer': return Icons.timer;
      case 'brain': return Icons.psychology;
      case 'army': return Icons.groups;
      default: return Icons.emoji_events;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
