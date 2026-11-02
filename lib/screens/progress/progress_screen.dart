import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../providers/player_provider.dart';
import '../../providers/quest_provider.dart';
import '../../config/constants.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ANALYTICS & PROGRESS',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer2<PlayerProvider, QuestProvider>(
        builder: (context, playerProvider, questProvider, _) {
          final user = playerProvider.user;
          final completedQuests = questProvider.completedQuests;
          final weeklyCompletions = questProvider.getWeeklyCompletions();
          final monthlyCompletions = questProvider.getMonthlyCompletions();
          final monthlyActiveDays = questProvider.getMonthlyActiveDays();
          final bestHabits = questProvider.bestPerformingHabits;
          final habitsNeedingWork = questProvider.habitsNeedingImprovement;
          final missedQuests = questProvider.missedQuests;

          // XP Line chart spots
          List<FlSpot> spots = [];
          if (completedQuests.isEmpty) {
            spots = [const FlSpot(0, 0)];
          } else {
            final sorted = List.of(completedQuests)
              ..sort((a, b) => (a.completedAt ?? DateTime.now())
                  .compareTo(b.completedAt ?? DateTime.now()));
            
            double currentXp = 0;
            for (int i = 0; i < sorted.length; i++) {
              currentXp += sorted[i].xpReward;
              spots.add(FlSpot(i.toDouble(), currentXp));
            }
          }

          // Weekdays max for chart scale
          int maxWeekly = 1;
          for (final count in weeklyCompletions.values) {
            if (count > maxWeekly) maxWeekly = count;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. High-Level Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'COMPLETION',
                        value: '${questProvider.overallCompletionPercent}%',
                        subtitle: '${questProvider.completedAllTime}/${questProvider.totalAllTime} all-time',
                        color: AppColors.cyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'ACTIVE STREAK',
                        value: '🔥 ${user?.streak ?? 0}',
                        subtitle: 'Best: ⚡ ${user?.bestStreak ?? 0} days',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'THIS MONTH',
                        value: '$monthlyCompletions',
                        subtitle: '$monthlyActiveDays active days',
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'MISSED HABITS',
                        value: '${missedQuests.length}',
                        subtitle: missedQuests.isEmpty ? 'All caught up!' : 'Past deadline',
                        color: missedQuests.isEmpty ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 2. Weekly Activity Bar Chart
                Text(
                  'WEEKLY COMPLETION PATTERN',
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 190,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.systemPanel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: (maxWeekly + 1).toDouble(),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: 1,
                            getTitlesWidget: (val, _) => Text(
                              '${val.toInt()}',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, _) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              final idx = val.toInt() - 1;
                              if (idx >= 0 && idx < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(days[idx], style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (i) {
                        final weekday = i + 1;
                        final count = weeklyCompletions[weekday] ?? 0;
                        return BarChartGroupData(
                          x: weekday,
                          barRods: [
                            BarChartRodData(
                              toY: count.toDouble(),
                              color: count > 0 ? AppColors.cyan : Colors.white12,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Habit-Wise Performance
                Text(
                  'TOP PERFORMING HABITS',
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (bestHabits.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.systemPanel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Text('Complete your first habit to see performance analytics.', style: TextStyle(color: Colors.white54)),
                  )
                else
                  ...bestHabits.take(5).map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.systemPanel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${entry.value} clears',
                              style: GoogleFonts.rajdhani(color: AppColors.cyan, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                const SizedBox(height: 28),

                // 4. Habits Needing Improvement
                if (habitsNeedingWork.isNotEmpty) ...[
                  Text(
                    'PENDING OBJECTIVES',
                    style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...habitsNeedingWork.take(4).map((q) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.systemPanel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              q.title,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            q.difficulty.label,
                            style: GoogleFonts.rajdhani(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 28),
                ],

                // 5. XP Growth Chart
                Text(
                  'XP GROWTH TRAJECTORY',
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.systemPanel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.cyan,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.cyan.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 6. Combat Stats
                Text(
                  'COMBAT STATS BREAKDOWN',
                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildStatBar('Strength (Fitness)', user?.stats['strength'] ?? 0, Colors.red),
                _buildStatBar('Intelligence (Study)', user?.stats['intelligence'] ?? 0, Colors.blue),
                _buildStatBar('Agility (Coding)', user?.stats['agility'] ?? 0, Colors.yellow),
                _buildStatBar('Vitality (Health)', user?.stats['vitality'] ?? 0, Colors.green),
                _buildStatBar('Perception (Reading)', user?.stats['perception'] ?? 0, Colors.purple),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.systemPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              Text('$value', style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
