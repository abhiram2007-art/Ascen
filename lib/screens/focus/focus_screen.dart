import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/quest_model.dart';
import '../../providers/player_provider.dart';
import '../../providers/quest_provider.dart';
import '../../config/constants.dart';

class FocusScreen extends StatefulWidget {
  final QuestModel quest;

  const FocusScreen({Key? key, required this.quest}) : super(key: key);

  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with TickerProviderStateMixin {
  int _secondsRemaining = 25 * 60; // 25 minutes default
  final int _totalSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;
  
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isPaused = true;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _secondsRemaining = _totalSeconds;
    });
  }

  void _giveUp() {
    _stopTimer();
    Navigator.pop(context);
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final questProvider = Provider.of<QuestProvider>(context, listen: false);
    final userId = playerProvider.user?.id;
    
    if (userId != null) {
      if (widget.quest.status != QuestStatus.completed) {
        await questProvider.completeQuest(userId, widget.quest.id);
        await playerProvider.addXP(
          userId: userId,
          difficulty: widget.quest.difficulty,
          statType: widget.quest.statType,
        );
      }
    }
    
    if (mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.cyan),
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'SYSTEM ALERT',
            style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Focus session complete.\nQuest [${widget.quest.title}] has been marked complete!',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to Home
              },
              child: Text('ACCEPT', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cyan),
        title: Text(
          'FOCUS MODE',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ACTIVE QUEST',
              style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 16, letterSpacing: 2),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                widget.quest.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 64),
            
            // Timer Display
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.2 + (_pulseController.value * 0.5)),
                          width: 2 + (_pulseController.value * 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cyan.withValues(alpha: 0.1 + (_pulseController.value * 0.2)),
                            blurRadius: 20,
                            spreadRadius: 10 * _pulseController.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Text(
                  _formattedTime,
                  style: GoogleFonts.orbitron(
                    color: AppColors.cyan,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: AppColors.cyan.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 64),
            
            // Controls
            if (!_isRunning || _isPaused)
              ElevatedButton(
                onPressed: _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.2),
                  side: const BorderSide(color: AppColors.cyan),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  _isPaused ? 'RESUME' : 'INITIATE',
                  style: GoogleFonts.orbitron(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: _pauseTimer,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('PAUSE', style: GoogleFonts.orbitron(color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _completeSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('COMPLETE', style: GoogleFonts.orbitron(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              
            const SizedBox(height: 24),
            
            if (_isRunning)
              TextButton(
                onPressed: _giveUp,
                child: Text('GIVE UP', style: GoogleFonts.rajdhani(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
