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
          'STATISTICS',
          style: GoogleFonts.orbitron(color: AppColors.cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'XP GROWTH',
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
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
                      spots: [
                        const FlSpot(0, 1),
                        const FlSpot(1, 1.5),
                        const FlSpot(2, 1.4),
                        const FlSpot(3, 3.4),
                        const FlSpot(4, 2),
                        const FlSpot(5, 2.2),
                        const FlSpot(6, 1.8),
                      ],
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
            const SizedBox(height: 32),
            Text(
              'COMBAT STATS',
              style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<PlayerProvider>(
              builder: (context, playerProvider, _) {
                final stats = playerProvider.user?.stats ?? {};
                return Column(
                  children: [
                    _buildStatBar('Strength (Fitness)', stats['str'] ?? 0, Colors.red),
                    _buildStatBar('Intelligence (Study)', stats['int'] ?? 0, Colors.blue),
                    _buildStatBar('Agility (Coding)', stats['agi'] ?? 0, Colors.yellow),
                    _buildStatBar('Vitality (Health)', stats['vit'] ?? 0, Colors.green),
                    _buildStatBar('Perception (Reading)', stats['per'] ?? 0, Colors.purple),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text('$value', style: GoogleFonts.orbitron(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (value / 100).clamp(0.0, 1.0), // Cap visual at 100
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
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
