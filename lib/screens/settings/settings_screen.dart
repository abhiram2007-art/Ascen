import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserEmail();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  void _saveNotificationPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }
  
  void _loadUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? 'No email';
      });
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.systemPanel,
        title: Text('DELETE ACCOUNT', style: GoogleFonts.orbitron(color: Colors.redAccent)),
        content: Text('Are you sure? This action cannot be undone.', style: GoogleFonts.rajdhani(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
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
          Text('PREFERENCES', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text('Notifications', style: GoogleFonts.orbitron(color: Colors.white)),
            value: _notificationsEnabled,
            onChanged: _saveNotificationPreference,
            activeColor: AppColors.cyan,
            inactiveTrackColor: Colors.white12,
          ),
          SwitchListTile(
            title: Text('Dark Mode', style: GoogleFonts.orbitron(color: Colors.white)),
            subtitle: const Text('Always on in Solo Leveling theme', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: true,
            onChanged: (val) {},
            activeColor: AppColors.cyan,
            inactiveTrackColor: Colors.white12,
          ),
          const SizedBox(height: 24),
          Text('ACCOUNT', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            title: Text('Email', style: GoogleFonts.orbitron(color: Colors.white)),
            subtitle: Text(_userEmail, style: const TextStyle(color: Colors.white70)),
          ),
          ListTile(
            title: Text('Delete Account', style: GoogleFonts.orbitron(color: Colors.redAccent)),
            onTap: _showDeleteAccountDialog,
          ),
          const SizedBox(height: 24),
          Text('ABOUT', style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            title: Text('Version', style: GoogleFonts.orbitron(color: Colors.white)),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
