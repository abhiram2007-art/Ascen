import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../services/level_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'HUNTER RANKINGS',
          style: GoogleFonts.orbitron(
            color: AppColors.cyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [const Shadow(color: AppColors.cyan, blurRadius: 10)],
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('totalXP', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No hunters found.',
                style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 18),
              ),
            );
          }
          
          final users = snapshot.data!.docs;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;
              final name = userData['name'] ?? 'Unknown Hunter';
              final totalXP = userData['totalXP'] ?? 0;
              final streak = userData['streak'] ?? 0;
              final level = LevelService.getCurrentLevel(totalXP);
              final rank = LevelService.getRank(level);
              final isCurrentUser = docId == currentUserId;
              
              return _buildRankCard(
                index: index,
                name: name,
                totalXP: totalXP,
                level: level,
                rankName: rank.name,
                rankColor: rank.color,
                streak: streak,
                isCurrentUser: isCurrentUser,
              ).animate()
                .fadeIn(delay: Duration(milliseconds: 100 * index), duration: 400.ms)
                .slideX(begin: 0.2, end: 0, duration: 400.ms);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildRankCard({
    required int index,
    required String name,
    required int totalXP,
    required int level,
    required String rankName,
    required Color rankColor,
    required int streak,
    required bool isCurrentUser,
  }) {
    final bool isTop3 = index < 3;
    final List<Color> topColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.cyan.withOpacity(0.15)
            : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.cyan
              : isTop3
                  ? topColors[index].withOpacity(0.6)
                  : Colors.white12,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: isTop3
            ? [BoxShadow(color: topColors[index].withOpacity(0.2), blurRadius: 10)]
            : null,
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 40,
            child: isTop3
                ? Icon(
                    Icons.emoji_events,
                    color: topColors[index],
                    size: 28,
                  )
                : Text(
                    '#${index + 1}',
                    style: GoogleFonts.orbitron(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: GoogleFonts.rajdhani(
                          color: isCurrentUser ? AppColors.cyan : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.orbitron(
                            color: AppColors.cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: rankColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        'Rank $rankName',
                        style: GoogleFonts.rajdhani(
                          color: rankColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lv.$level',
                      style: GoogleFonts.orbitron(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🔥$streak',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatXP(totalXP)}',
                style: GoogleFonts.orbitron(
                  color: AppColors.gold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: AppColors.gold, blurRadius: 4)],
                ),
              ),
              Text(
                'XP',
                style: GoogleFonts.rajdhani(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  String _formatXP(int xp) {
    if (xp >= 1000000) return '${(xp / 1000000).toStringAsFixed(1)}M';
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}K';
    return xp.toString();
  }
}
