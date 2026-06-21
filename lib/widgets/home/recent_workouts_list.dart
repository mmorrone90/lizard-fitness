import 'package:flutter/material.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:intl/intl.dart';

class RecentWorkoutsList extends StatelessWidget {
  final List<WorkoutSession> sessions;
  const RecentWorkoutsList({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Workouts', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...sessions.map((s) => _WorkoutRow(session: s)),
        ],
      ),
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  final WorkoutSession session;
  const _WorkoutRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final completed = session.completedAt;
    final duration = session.duration;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center, color: kYellow, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.workoutTitle, style: Theme.of(context).textTheme.titleMedium),
                if (completed != null)
                  Text(
                    DateFormat('EEE, MMM d').format(completed),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (duration != null)
                Text('${duration}min', style: Theme.of(context).textTheme.titleSmall),
              Text(
                '${session.totalVolume.toStringAsFixed(0)}kg',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
