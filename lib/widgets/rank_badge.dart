import 'package:flutter/material.dart';
import '../config/constants.dart';

class RankBadge extends StatefulWidget {
  final String rank;
  final String size; // 'small', 'medium', 'large'

  const RankBadge({
    Key? key,
    required this.rank,
    this.size = 'medium',
  }) : super(key: key);

  @override
  _RankBadgeState createState() => _RankBadgeState();
}

class _RankBadgeState extends State<RankBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'E': return AppColors.rankE;
      case 'D': return AppColors.rankD;
      case 'C': return AppColors.rankC;
      case 'B': return AppColors.rankB;
      case 'A': return AppColors.rankA;
      case 'S': return AppColors.rankS;
      default: return AppColors.rankE;
    }
  }

  double _getSize() {
    switch (widget.size) {
      case 'small': return 24.0;
      case 'large': return 64.0;
      case 'medium':
      default: return 40.0;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case 'small': return 14.0;
      case 'large': return 36.0;
      case 'medium':
      default: return 24.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(widget.rank);
    final size = _getSize();
    final isSRank = widget.rank.toUpperCase() == 'S';

    Widget badgeContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(
          color: rankColor,
          width: size * 0.05,
        ),
        boxShadow: [
          BoxShadow(
            color: rankColor.withValues(alpha: 0.3),
            blurRadius: size * 0.2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.rank.toUpperCase(),
          style: TextStyle(
            color: rankColor,
            fontFamily: AppFonts.orbitron,
            fontWeight: FontWeight.bold,
            fontSize: _getFontSize(),
          ),
        ),
      ),
    );

    if (isSRank) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.2),
              boxShadow: [
                BoxShadow(
                  color: rankColor.withValues(alpha: 0.5 * _controller.value),
                  blurRadius: size * 0.5 * _controller.value,
                  spreadRadius: size * 0.1 * _controller.value,
                ),
              ],
            ),
            child: badgeContent,
          );
        },
      );
    }

    return badgeContent;
  }
}
