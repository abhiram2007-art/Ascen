import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const QuestCard({
    Key? key,
    required this.quest,
    this.onTap,
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = quest.status == QuestStatus.completed;
    final String title = quest.title;
    final int xpReward = quest.xpReward;
    final String difficulty = quest.difficulty.label;
    
    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isCompleted ? Colors.green.withOpacity(0.5) : AppColors.cyan.withOpacity(0.8),
              width: 1.5,
            ),
            boxShadow: [
              if (!isCompleted)
                BoxShadow(
                  color: AppColors.cyan.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : AppColors.cyan,
                    boxShadow: [
                      BoxShadow(
                        color: isCompleted ? Colors.green : AppColors.cyan,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: Colors.white30, width: 0.5),
                                    ),
                                    child: Text(
                                      'Rank $difficulty',
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '+$xpReward XP',
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.gold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        const Shadow(color: AppColors.gold, blurRadius: 4),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isCompleted)
                          const Icon(Icons.check_circle, color: Colors.green, size: 28)
                              .animate()
                              .scale(duration: 400.ms, curve: Curves.easeOutBack)
                        else
                          IconButton(
                            icon: const Icon(Icons.radio_button_unchecked, color: AppColors.cyan),
                            onPressed: onComplete,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic)
        .shimmer(delay: 1000.ms, duration: 2000.ms, color: Colors.white24, angle: 1),
      ),
    );
  }
}
