import 'package:flutter/material.dart';
import '../config/constants.dart';

class SystemWindow extends StatefulWidget {
  final Widget child;
  final String? title;
  final IconData? headerIcon;
  final EdgeInsetsGeometry padding;

  const SystemWindow({
    Key? key,
    required this.child,
    this.title,
    this.headerIcon,
    this.padding = const EdgeInsets.all(16.0),
  }) : super(key: key);

  @override
  _SystemWindowState createState() => _SystemWindowState();
}

class _SystemWindowState extends State<SystemWindow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.systemPanel.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cyan.withValues(alpha: _isHovered ? 0.8 : 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cyan.withValues(alpha: _isHovered ? 0.2 : 0.05),
              blurRadius: _isHovered ? 15 : 8,
              spreadRadius: _isHovered ? 2 : 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.title != null || widget.headerIcon != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.cyan.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.headerIcon != null) ...[
                        Icon(widget.headerIcon, color: AppColors.cyan, size: 18),
                        const SizedBox(width: 8),
                      ],
                      if (widget.title != null)
                        Text(
                          widget.title!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.orbitron,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: widget.padding,
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
