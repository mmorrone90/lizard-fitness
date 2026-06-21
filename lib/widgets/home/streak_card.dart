import 'package:flutter/material.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class StreakCard extends StatelessWidget {
  final int streak;
  const StreakCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: streak > 0 ? Border.all(color: kYellow.withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text('STREAK', style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: kYellow),
          ),
          Text(
            streak == 1 ? 'day' : 'days',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
