import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class XPBar extends StatelessWidget {
  final int currentXP;
  final int requiredXP;

  const XPBar({
    Key? key,
    required this.currentXP,
    required this.requiredXP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = requiredXP > 0 ? currentXP / requiredXP : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$currentXP / $requiredXP XP',
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF00D4FF),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [
              const Shadow(color: Color(0xFF00D4FF), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(0), // Sharp edges
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D4FF),
                    boxShadow: [
                      BoxShadow(color: Color(0xFF00D4FF), blurRadius: 10, spreadRadius: 1),
                    ],
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, color: Colors.white54, angle: 1.5),
              ),
            ],
          ),
        )
        .animate()
        .scaleX(begin: 0.0, end: 1.0, duration: 800.ms, curve: Curves.easeOutExpo, alignment: Alignment.centerLeft),
      ],
    );
  }
}
