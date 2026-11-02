import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onUncomplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const QuestCard({
    Key? key,
    required this.quest,
    this.onTap,
    this.onComplete,
    this.onUncomplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = quest.status == QuestStatus.completed;
    final String title = quest.title;
    final int xpReward = quest.xpReward;
    final String difficulty = quest.difficulty.label;
    
    return Opacity(
      opacity: isCompleted ? 0.65 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCompleted ? Colors.green.withValues(alpha: 0.5) : AppColors.cyan.withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              if (!isCompleted)
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Color bar on left edge
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : AppColors.cyan,
                    boxShadow: [
                      BoxShadow(
                        color: isCompleted ? Colors.green : AppColors.cyan,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            // Action buttons
                            if (isCompleted)
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 26),
                                tooltip: 'Mark Incomplete',
                                onPressed: onUncomplete,
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.radio_button_unchecked, color: AppColors.cyan, size: 26),
                                tooltip: 'Claim XP',
                                onPressed: onComplete,
                              ),
                            if (onEdit != null || onDelete != null)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                                color: const Color(0xFF1E293B),
                                onSelected: (value) {
                                  if (value == 'edit') onEdit?.call();
                                  if (value == 'delete') onDelete?.call();
                                  if (value == 'uncomplete') onUncomplete?.call();
                                  if (value == 'focus') onTap?.call();
                                },
                                itemBuilder: (context) => [
                                  if (!isCompleted)
                                    const PopupMenuItem(
                                      value: 'focus',
                                      child: Row(
                                        children: [
                                          Icon(Icons.timer, color: AppColors.cyan, size: 18),
                                          SizedBox(width: 8),
                                          Text('Start Focus Session', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  if (isCompleted)
                                    const PopupMenuItem(
                                      value: 'uncomplete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.undo, color: Colors.orangeAccent, size: 18),
                                          SizedBox(width: 8),
                                          Text('Mark Incomplete', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  if (onEdit != null)
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.white70, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit Habit', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  if (onDelete != null)
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                          SizedBox(width: 8),
                                          Text('Delete Habit', style: TextStyle(color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        if (quest.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            quest.description,
                            style: const TextStyle(color: Colors.white54, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.white24, width: 0.5),
                              ),
                              child: Text(
                                'Rank $difficulty',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cyan.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                quest.category,
                                style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 12),
                              ),
                            ),
                            if (quest.isRecurring)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.repeat, size: 12, color: Colors.purpleAccent),
                                    SizedBox(width: 4),
                                    Text('Daily', style: TextStyle(color: Colors.purpleAccent, fontSize: 11)),
                                  ],
                                ),
                              ),
                            if (quest.reminderTime != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.alarm, size: 12, color: Colors.orangeAccent),
                                    const SizedBox(width: 4),
                                    Text(quest.reminderTime!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                                  ],
                                ),
                              ),
                            Text(
                              '+$xpReward XP',
                              style: GoogleFonts.orbitron(
                                color: AppColors.gold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
