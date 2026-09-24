import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/quest_provider.dart';
import '../../models/quest_model.dart';
import '../../config/constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<QuestModel> _getQuestsForDay(DateTime day, List<QuestModel> completedQuests) {
    return completedQuests.where((quest) {
      if (quest.completedAt == null) return false;
      return isSameDay(quest.completedAt, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'QUEST HISTORY',
          style: GoogleFonts.orbitron(
            color: AppColors.cyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<QuestProvider>(
        builder: (context, questProvider, _) {
          final completedQuests = questProvider.completedQuests;
          final selectedQuests = _getQuestsForDay(_selectedDay!, completedQuests);

          return Column(
            children: [
              TableCalendar<QuestModel>(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) => _getQuestsForDay(day, completedQuests),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white70),
                  weekendTextStyle: const TextStyle(color: Colors.white54),
                  outsideTextStyle: const TextStyle(color: Colors.white24),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  todayDecoration: BoxDecoration(
                    color: AppColors.cyan.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: GoogleFonts.orbitron(color: Colors.white, fontSize: 16),
                  formatButtonVisible: false,
                  leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.cyan),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.cyan),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: AppColors.cyan),
                  weekendStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white24),
              const SizedBox(height: 8),
              Expanded(
                child: selectedQuests.isEmpty
                    ? Center(
                        child: Text(
                          'No quests completed on this day.',
                          style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: selectedQuests.length,
                        itemBuilder: (context, index) {
                          final quest = selectedQuests[index];
                          return _buildHistoryCard(quest)
                              .animate()
                              .fadeIn(delay: Duration(milliseconds: 100 * index))
                              .slideX(begin: 0.2);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(QuestModel quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  quest.title,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '+${quest.xpReward} XP',
                  style: GoogleFonts.orbitron(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (quest.timeSpentMins != null || (quest.completionNotes != null && quest.completionNotes!.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (quest.timeSpentMins != null)
                    Row(
                      children: [
                        const Icon(Icons.timer, color: AppColors.cyan, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          '${quest.timeSpentMins} minutes',
                          style: GoogleFonts.rajdhani(color: Colors.white70),
                        ),
                      ],
                    ),
                  if (quest.timeSpentMins != null && quest.completionNotes != null && quest.completionNotes!.isNotEmpty)
                    const SizedBox(height: 8),
                  if (quest.completionNotes != null && quest.completionNotes!.isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.edit_note, color: Colors.white54, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            quest.completionNotes!,
                            style: GoogleFonts.rajdhani(color: Colors.white, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
