import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';
import '../providers/quest_provider.dart';
import 'home/home_screen.dart';

import 'progress/progress_screen.dart';
import 'ai_coach/ai_coach_screen.dart';
import 'profile/profile_screen.dart';
import 'quests/quests_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'guild/guild_screen.dart';
import '../widgets/offline_banner.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeScreen(),
    const QuestsScreen(),
    const GuildScreen(),
    const LeaderboardScreen(),
    const AiCoachScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initProviders();
  }

  void _initProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;
      
      if (userId != null) {
        // 1. Load user and start listening
        Provider.of<PlayerProvider>(context, listen: false).listenToUser(userId);
        
        // 2. Reset daily quests for new day, THEN start listening
        await Provider.of<QuestProvider>(context, listen: false).initAndListen(userId);
        
        // 3. Update streak on app open
        await Provider.of<PlayerProvider>(context, listen: false).updateStreak(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: OfflineBannerWrapper(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF00D4FF).withOpacity(0.2),
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF12121A),
          selectedItemColor: const Color(0xFF00D4FF),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: 'Quests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined),
              activeIcon: Icon(Icons.shield),
              label: 'Guild',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              label: 'Ranks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_rounded),
              label: 'AI Coach',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
