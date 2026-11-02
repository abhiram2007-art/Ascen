import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/quest_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/quest_model.dart';
import '../../config/constants.dart';
import '../../widgets/quest_card.dart';
import '../../config/routes.dart';
import '../../utils/quest_dialogs.dart';
import '../add_quest/add_quest_screen.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Daily',
    'Habit',
    'Main',
    'Side',
    'Challenge',
    'Pending',
    'Completed',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuestModel> _filterQuests(List<QuestModel> allQuests) {
    return allQuests.where((quest) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = quest.title.toLowerCase().contains(query);
        final matchesDesc = quest.description.toLowerCase().contains(query);
        final matchesCat = quest.category.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesCat) return false;
      }

      // 2. Category / Status Filter
      switch (_selectedFilter) {
        case 'Daily':
          return quest.type == QuestType.daily;
        case 'Habit':
          return quest.type == QuestType.habit;
        case 'Main':
          return quest.type == QuestType.main;
        case 'Side':
          return quest.type == QuestType.side;
        case 'Challenge':
          return quest.type == QuestType.challenge;
        case 'Pending':
          return quest.status != QuestStatus.completed;
        case 'Completed':
          return quest.status == QuestStatus.completed;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  void _confirmDeleteQuest(BuildContext context, String userId, QuestModel quest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.systemPanel,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'DELETE QUEST',
          style: GoogleFonts.orbitron(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${quest.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<QuestProvider>(context, listen: false).deleteQuest(userId, quest.id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
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
          'QUEST DIRECTORY',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<QuestProvider, PlayerProvider>(
        builder: (context, questProvider, playerProvider, _) {
          if (questProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.cyan));
          }

          final user = playerProvider.user;
          final allQuests = questProvider.allQuests;
          final filteredQuests = _filterQuests(allQuests);

          return Column(
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Search quests, categories...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: AppColors.cyan),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.systemPanel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cyan),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.cyan.withValues(alpha: 0.25),
                      backgroundColor: AppColors.systemPanel,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.cyan : Colors.white60,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.cyan : Colors.white12,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedFilter = filter);
                      },
                    );
                  },
                ),
              ),

              // Status Summary bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredQuests.length} ${filteredQuests.length == 1 ? 'QUEST' : 'QUESTS'}',
                      style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${questProvider.completedToday}/${questProvider.totalToday} Daily Done',
                      style: GoogleFonts.rajdhani(color: AppColors.cyan, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10),

              // Quest List
              Expanded(
                child: filteredQuests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_outlined, size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'No quests match "$_searchQuery"'
                                  : 'No quests in "$_selectedFilter"',
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: filteredQuests.length,
                        itemBuilder: (context, index) {
                          final quest = filteredQuests[index];
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
                                final authUser = Provider.of<AuthProvider>(context, listen: false).user;
                                final targetUserId = user?.id ?? authUser?.uid;
                                if (quest.status != QuestStatus.completed && targetUserId != null) {
                                  showQuestCompletionDialog(
                                    context,
                                    quest,
                                    targetUserId,
                                    questProvider,
                                    playerProvider,
                                  );
                                }
                              },
                              onUncomplete: () async {
                                final authUser = Provider.of<AuthProvider>(context, listen: false).user;
                                final targetUserId = user?.id ?? authUser?.uid;
                                if (targetUserId != null) {
                                  await questProvider.uncompleteQuest(targetUserId, quest.id);
                                }
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddQuestScreen(initialQuest: quest),
                                  ),
                                );
                              },
                              onDelete: () {
                                final authUser = Provider.of<AuthProvider>(context, listen: false).user;
                                final targetUserId = user?.id ?? authUser?.uid;
                                if (targetUserId != null) {
                                  _confirmDeleteQuest(context, targetUserId, quest);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addQuest);
        },
        backgroundColor: const Color(0xFF0A0A0F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(color: AppColors.cyan, width: 1.5),
        ),
        child: const Icon(Icons.add, color: AppColors.cyan),
      ),
    );
  }
}
