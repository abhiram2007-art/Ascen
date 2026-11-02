import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (kIsWeb) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android Initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS Initialization
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          // Notification tap handler
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        final granted = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  Future<void> showSystemAlert({required String title, required String body}) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint('System Alert: $title - $body');
      return;
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'system_alerts',
        'System Alerts',
        channelDescription: 'Crucial notifications from the System',
        importance: Importance.max,
        priority: Priority.high,
        color: Color(0xFF00D4FF),
        ticker: 'ticker',
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('showSystemAlert error: $e');
    }
  }

  /// Schedule daily morning and evening reminders
  Future<void> scheduleDailyReminders({
    int morningHour = 8,
    int morningMinute = 0,
    int eveningHour = 20,
    int eveningMinute = 0,
  }) async {
    if (kIsWeb || !_isInitialized) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'daily_quests',
        'Daily Quests',
        channelDescription: 'Reminders to complete daily quests',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF00D4FF),
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      // Morning reminder using inexactAllowWhileIdle for safe Android 12+ execution
      await flutterLocalNotificationsPlugin.zonedSchedule(
        101,
        'SYSTEM ALERT: Daily Quests Awakened',
        'Hunter, your daily quests have reset. Begin your training early.',
        _nextInstanceOfTime(morningHour, morningMinute),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Evening reminder for pending quests
      await flutterLocalNotificationsPlugin.zonedSchedule(
        102,
        'SYSTEM ALERT: Pending Quests Remaining',
        'Player, you have incomplete objectives. Clear them before midnight to maintain your streak.',
        _nextInstanceOfTime(eveningHour, eveningMinute),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleDailyReminders error: $e');
    }
  }

  Future<void> scheduleDailyQuestReminder() async {
    await scheduleDailyReminders();
  }

  /// Schedule custom reminder for an individual habit
  Future<void> scheduleHabitReminder({
    required int id,
    required String title,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb || !_isInitialized) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Custom reminders for specific habits',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFF00D4FF),
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'QUEST REMINDER: $title',
        'Time to complete your quest: $title',
        _nextInstanceOfTime(hour, minute),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleHabitReminder error: $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    if (kIsWeb || !_isInitialized) return;
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('cancelReminder error: $e');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb || !_isInitialized) return;
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint('cancelAll error: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    } catch (e) {
      debugPrint('Timezone error in _nextInstanceOfTime: $e');
      final tz.Location utc = tz.getLocation('UTC');
      final tz.TZDateTime now = tz.TZDateTime.now(utc);
      tz.TZDateTime scheduledDate = tz.TZDateTime(utc, now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      return scheduledDate;
    }
  }
}
