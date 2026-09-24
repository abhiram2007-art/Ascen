import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/quest_provider.dart';
import '../../providers/player_provider.dart';
import '../../models/quest_model.dart';
import '../../config/constants.dart';
import '../../widgets/quest_card.dart';
import '../../config/routes.dart';
import '../../utils/quest_dialogs.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ALL QUESTS',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<QuestProvider, PlayerProvider>(
        builder: (context, questProvider, playerProvider, _) {
          if (questProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final quests = questProvider.allQuests;
          final user = playerProvider.user;

          if (quests.isEmpty) {
            return const Center(
              child: Text(
                'No active quests found.\nCreate one to begin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quests.length,
            itemBuilder: (context, index) {
              final quest = quests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: QuestCard(
                  quest: quest,
                  onTap: () {
                    if (quest.status != QuestStatus.completed) {
                      Navigator.pushNamed(context, AppRoutes.focus, arguments: quest);
                    }
                  },
                  onComplete: () async {
                    if (quest.status != QuestStatus.completed && user != null) {
                      showQuestCompletionDialog(
                        context,
                        quest,
                        user.id,
                        questProvider,
                        playerProvider,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
