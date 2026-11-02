import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _morningHour = 8;
  int _morningMinute = 0;
  int _eveningHour = 20;
  int _eveningMinute = 0;
  String _userEmail = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserInfo();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _morningHour = prefs.getInt('morningHour') ?? 8;
      _morningMinute = prefs.getInt('morningMinute') ?? 0;
      _eveningHour = prefs.getInt('eveningHour') ?? 20;
      _eveningMinute = prefs.getInt('eveningMinute') ?? 0;
    });
  }

  void _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyReminders(
        morningHour: _morningHour,
        morningMinute: _morningMinute,
        eveningHour: _eveningHour,
        eveningMinute: _eveningMinute,
      );
    } else {
      await NotificationService().cancelAll();
    }
  }

  void _pickMorningTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _morningHour, minute: _morningMinute),
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('morningHour', picked.hour);
      await prefs.setInt('morningMinute', picked.minute);
      setState(() {
        _morningHour = picked.hour;
        _morningMinute = picked.minute;
      });

      if (_notificationsEnabled) {
        await NotificationService().scheduleDailyReminders(
          morningHour: _morningHour,
          morningMinute: _morningMinute,
          eveningHour: _eveningHour,
          eveningMinute: _eveningMinute,
        );
      }
    }
  }

  void _pickEveningTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _eveningHour, minute: _eveningMinute),
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('eveningHour', picked.hour);
      await prefs.setInt('eveningMinute', picked.minute);
      setState(() {
        _eveningHour = picked.hour;
        _eveningMinute = picked.minute;
      });

      if (_notificationsEnabled) {
        await NotificationService().scheduleDailyReminders(
          morningHour: _morningHour,
          morningMinute: _morningMinute,
          eveningHour: _eveningHour,
          eveningMinute: _eveningMinute,
        );
      }
    }
  }

  void _testNotification() async {
    await NotificationService().requestPermissions();
    await NotificationService().showSystemAlert(
      title: 'SYSTEM NOTIFICATION: ACTIVE',
      body: 'Hunter, communication link confirmed. Daily quest monitoring operational.',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test System Alert sent!'),
          backgroundColor: AppColors.cyan,
        ),
      );
    }
  }
  
  void _loadUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? 'No email';
        _userId = user.uid;
      });
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.systemPanel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text('DELETE ACCOUNT', style: GoogleFonts.orbitron(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: const Text(
          'Warning: This action will permanently erase your player profile, quests, and rankings. This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await user.delete();
                } catch (e) {
                  // If requires re-auth, sign out
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                }
              }
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text('CONFIRM DELETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SETTINGS',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: AppColors.cyan),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // PREFERENCES
          Text('NOTIFICATIONS & REMINDERS', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('System Alerts & Reminders', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
            subtitle: const Text('Daily morning & evening quest reminders', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: _notificationsEnabled,
            onChanged: _saveNotificationPreference,
            activeColor: AppColors.cyan,
            inactiveTrackColor: Colors.white12,
          ),
          if (_notificationsEnabled) ...[
            ListTile(
              title: const Text('Morning Reset Reminder', style: TextStyle(color: Colors.white70)),
              subtitle: Text(_formatTime(_morningHour, _morningMinute), style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.access_time, color: AppColors.cyan),
              onTap: _pickMorningTime,
            ),
            ListTile(
              title: const Text('Evening Incomplete Warning', style: TextStyle(color: Colors.white70)),
              subtitle: Text(_formatTime(_eveningHour, _eveningMinute), style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.access_time, color: AppColors.cyan),
              onTap: _pickEveningTime,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cyan),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.notifications_active, color: AppColors.cyan, size: 18),
                label: Text('TEST SYSTEM NOTIFICATION', style: GoogleFonts.orbitron(color: AppColors.cyan, fontSize: 12)),
                onPressed: _testNotification,
              ),
            ),
          ],
          const SizedBox(height: 24),

          // THEME
          Text('SYSTEM INTERFACE', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Dark Mode (Monarch Theme)', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
            subtitle: const Text('Solo Leveling deep shadow palette is active', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: true,
            onChanged: (val) {},
            activeColor: AppColors.cyan,
            inactiveTrackColor: Colors.white12,
          ),
          const SizedBox(height: 24),

          // ACCOUNT
          Text('PLAYER ACCOUNT', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            title: Text('Email', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
            subtitle: Text(_userEmail, style: const TextStyle(color: Colors.white70)),
          ),
          if (_userId.isNotEmpty)
            ListTile(
              title: Text('Hunter ID', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
              subtitle: Text(_userId, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ListTile(
            title: Text('Delete Account', style: GoogleFonts.orbitron(color: Colors.redAccent, fontSize: 14)),
            subtitle: const Text('Permanently erase player data and progress', style: TextStyle(color: Colors.white38, fontSize: 12)),
            onTap: _showDeleteAccountDialog,
          ),
          const SizedBox(height: 24),

          // ABOUT
          Text('SYSTEM INFORMATION', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            title: Text('Ascend Version', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
            trailing: const Text('2.0.0 (Production Ready)', style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text('Engine', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14)),
            trailing: const Text('Flutter & Cloud Firestore', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
