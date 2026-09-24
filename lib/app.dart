import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/player_provider.dart';
import 'providers/quest_provider.dart';
import 'providers/guild_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_shell.dart';
import 'screens/add_quest/add_quest_screen.dart';
import 'screens/focus/focus_screen.dart';
import 'screens/history/history_screen.dart';
import 'models/quest_model.dart';

class AscendApp extends StatelessWidget {
  const AscendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProxyProvider<PlayerProvider, GuildProvider>(
          create: (_) => GuildProvider(),
          update: (_, player, guild) {
            final guildId = player.user?.guildId;
            if (guild?.currentGuild?.id != guildId) {
              guild?.init(guildId);
            }
            return guild!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ASCEND',
        theme: ascendDarkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return _buildRoute(const SplashScreen(), settings);
            case AppRoutes.login:
              return _buildRoute(const LoginScreen(), settings);
            case AppRoutes.register:
              return _buildRoute(const RegisterScreen(), settings);
            case AppRoutes.onboarding:
              return _buildRoute(const OnboardingScreen(), settings);
            case AppRoutes.home:
              return _buildRoute(const MainShell(), settings);
            case AppRoutes.addQuest:
              return _buildRoute(const AddQuestScreen(), settings);
            case AppRoutes.history:
              return _buildRoute(const HistoryScreen(), settings);
            case AppRoutes.focus:
              if (settings.arguments is QuestModel) {
                return _buildRoute(FocusScreen(quest: settings.arguments as QuestModel), settings);
              }
              return _buildRoute(const MainShell(), settings); // fallback
            default:
              return _buildRoute(
                Scaffold(
                  backgroundColor: const Color(0xFF0A0A0F),
                  body: Center(
                    child: Text(
                      'Coming Soon: ${settings.name}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                settings,
              );
          }
        },
      ),
    );
  }

  MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}
