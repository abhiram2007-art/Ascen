import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Safely initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization exception: $e");
  }
  
  // 2. Safely load .env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }

  // 3. Safely init notifications (never block runApp)
  if (!kIsWeb) {
    try {
      await NotificationService().init();
      await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyQuestReminder();
    } catch (e) {
      debugPrint("Notification init/schedule error on startup: $e");
    }
  }
  
  runApp(const AscendApp());
}
