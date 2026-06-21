import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:intl/intl.dart';

class VolumeChart extends StatelessWidget {
  final List<WorkoutSession> sessions;
  const VolumeChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final completed = sessions.where((s) => s.completedAt != null && s.totalVolume > 0).toList()
      ..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));

    if (completed.isEmpty) return const SizedBox();

    final spots = completed.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value.totalVolume),
    ).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Volume Progress', style: Theme.of(context).textTheme.headlineSmall),
          Text('Total weight lifted per session', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => const FlLine(color: kCardLight, strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= completed.length) return const SizedBox();
                        return Text(
                          DateFormat('d/M').format(completed[i].completedAt!),
                          style: const TextStyle(color: kTextMuted, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (v, _) => Text(
                        NumberFormat('#,##0').format(v),
                        style: const TextStyle(color: kTextMuted, fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: kYellow,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4, color: kYellow, strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [kYellow.withOpacity(0.2), kYellow.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
