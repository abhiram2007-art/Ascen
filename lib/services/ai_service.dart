import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  late final GenerativeModel _model;
  bool _isInitialized = false;

  AiService() {
    _initModel();
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system('You are the System from Solo Leveling. You refer to the user as "Player". Your tone is cold, precise, encouraging but demanding. Keep responses concise, no more than 2-3 sentences.'),
      );
      _isInitialized = true;
    }
  }

  Future<String> getCoachResponse(String userMessage, Map<String, dynamic> playerStats) async {
    if (!_isInitialized) {
      return "SYSTEM ERROR: API Link severed. Please insert GEMINI_API_KEY into the configuration.";
    }

    try {
      final prompt = '''
Player Stats:
Level: \${playerStats['level']}
Rank: \${playerStats['rank']}
XP: \${playerStats['xp']}
Streak: \${playerStats['streak']}

Player Message: $userMessage
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "SYSTEM ERROR: No response generated.";
    } catch (e) {
      return "SYSTEM ERROR: Communication failed. \$e";
    }
  }
}
