import 'package:flutter/material.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WeeklySummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;
  const WeeklySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final sessions = summary['sessionsCount'] as int? ?? 0;
    final volume = (summary['totalVolume'] as double? ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: kYellow, size: 18),
              const SizedBox(width: 6),
              Text('THIS WEEK', style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$sessions',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: kYellow),
          ),
          Text('sessions', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            '${NumberFormat('#,##0').format(volume)} kg',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text('volume', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
