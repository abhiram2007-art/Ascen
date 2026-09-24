import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgFade;
  late Animation<double> _initFade;
  late Animation<double> _progressAnim;
  late Animation<double> _playerFade;
  late Animation<double> _ascendFade;

  String _systemText = "";
  final String _fullSystemText = "SYSTEM";
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500));

    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn)));
    _initFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.45, curve: Curves.easeIn)));
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.75, curve: Curves.easeInOut)));
    _playerFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.85, curve: Curves.easeIn)));
    _ascendFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn)));

    _controller.forward();

    // Typewriter effect starts at ~500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        int index = 0;
        _typewriterTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
          if (index < _fullSystemText.length) {
            setState(() {
              _systemText = _fullSystemText.substring(0, index + 1);
            });
            index++;
          } else {
            timer.cancel();
          }
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isAuthenticated) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Color(0xFF0F172A), // Dark blue hint
                Color(0xFF0A0A0F),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SYSTEM text with typewriter
              SizedBox(
                height: 40,
                child: Text(
                  _systemText,
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00D4FF),
                    letterSpacing: 8.0,
                    shadows: [
                      const Shadow(
                        color: Color(0xFF00D4FF),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // INITIALIZING text
              FadeTransition(
                opacity: _initFade,
                child: Text(
                  'INITIALIZING...',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Progress Bar
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  return Container(
                    width: 200,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _progressAnim.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4FF),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF00D4FF),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // PLAYER DETECTED
              FadeTransition(
                opacity: _playerFade,
                child: Text(
                  'PLAYER DETECTED',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00D4FF),
                    letterSpacing: 4.0,
                    shadows: [
                      const Shadow(
                        color: Color(0xFF00D4FF),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // ASCEND title
              FadeTransition(
                opacity: _ascendFade,
                child: Text(
                  'A S C E N D',
                  style: GoogleFonts.rajdhani(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFFD700),
                    letterSpacing: 12.0,
                    shadows: [
                      const Shadow(
                        color: Color(0xFFFFD700),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
