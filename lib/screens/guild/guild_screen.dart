import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/guild_provider.dart';
import '../../providers/player_provider.dart';
import '../../config/constants.dart';

class GuildScreen extends StatefulWidget {
  const GuildScreen({Key? key}) : super(key: key);

  @override
  State<GuildScreen> createState() => _GuildScreenState();
}

class _GuildScreenState extends State<GuildScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'GUILDS',
          style: GoogleFonts.orbitron(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<GuildProvider, PlayerProvider>(
        builder: (context, guildProvider, playerProvider, _) {
          final user = playerProvider.user;
          final guild = guildProvider.currentGuild;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (guildProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }

          if (user.guildId == null || guild == null) {
            return _buildNoGuildView(context, guildProvider, user.id);
          }

          return _buildGuildDashboard(guild, guildProvider, user.id);
        },
      ),
    );
  }

  Widget _buildNoGuildView(BuildContext context, GuildProvider guildProvider, String userId) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield, size: 80, color: Colors.white24),
          const SizedBox(height: 24),
          Text(
            'YOU ARE A LONE WOLF',
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Join or create a guild to collaborate with other hunters, earn shared XP, and climb the Guild Ranks.',
            style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildTextField('Guild Name', _nameController),
          const SizedBox(height: 16),
          _buildTextField('Description', _descController),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_nameController.text.isEmpty) return;
                await guildProvider.createGuild(_nameController.text, _descController.text, userId);
              },
              child: Text(
                'CREATE GUILD',
                style: GoogleFonts.orbitron(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Or', style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // To do: Show join guild dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Join Guild feature coming soon! (Search by ID)')),
                );
              },
              child: Text(
                'JOIN GUILD (Coming Soon)',
                style: GoogleFonts.orbitron(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuildDashboard(guild, GuildProvider guildProvider, String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Column(
              children: [
                Text(
                  guild.name.toUpperCase(),
                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'GUILD LEVEL ${guild.level}',
                  style: GoogleFonts.rajdhani(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 24),
                Text(
                  '${guild.totalXP} TOTAL XP',
                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 24),
                Text(
                  guild.description,
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'MEMBERS (${guild.memberIds.length})',
              style: GoogleFonts.orbitron(color: Colors.white54, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // We don't fetch full members here to keep it simple, just count
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guild.memberIds.length,
            itemBuilder: (context, index) {
              final memberId = guild.memberIds[index];
              final isMe = memberId == userId;
              final isLeader = memberId == guild.leaderId;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isLeader ? AppColors.gold.withOpacity(0.2) : Colors.white12,
                  child: Icon(isLeader ? Icons.star : Icons.person, color: isLeader ? AppColors.gold : Colors.white),
                ),
                title: Text(isMe ? 'You' : 'Member $memberId', style: const TextStyle(color: Colors.white)),
                subtitle: Text(isLeader ? 'Guild Master' : 'Hunter', style: const TextStyle(color: Colors.white54)),
              );
            },
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => guildProvider.leaveGuild(userId),
            child: Text('Leave Guild', style: TextStyle(color: Colors.redAccent.shade400)),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.gold),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
