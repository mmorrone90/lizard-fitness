import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:intl/intl.dart';

class WorkoutCompletionScreen extends StatelessWidget {
  final WorkoutSession? session;
  const WorkoutCompletionScreen({super.key, this.session});

  @override
  Widget build(BuildContext context) {
    final s = session;

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kYellow.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: kYellow, width: 2),
                  ),
                  child: const Icon(Icons.check, color: kYellow, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text('Workout Complete!', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: kYellow)),
              ),
              if (s != null) ...[
                const SizedBox(height: 8),
                Center(child: Text(s.workoutTitle, style: Theme.of(context).textTheme.headlineSmall)),
              ],
              const SizedBox(height: 36),
              if (s != null) ...[
                _StatRow(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: '${s.duration ?? 0} min',
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.fitness_center,
                  label: 'Exercises',
                  value: '${s.completedExercises.length}',
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.bar_chart,
                  label: 'Total Volume',
                  value: '${NumberFormat('#,##0').format(s.totalVolume)} kg',
                ),
                const SizedBox(height: 12),
                _StatRow(
                  icon: Icons.check_circle_outline,
                  label: 'Sets Completed',
                  value: '${s.completedExercises.fold(0, (sum, e) => sum + e.completedSets)}',
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('BACK TO HOME'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/workout'),
                child: const Text('VIEW WORKOUTS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: kYellow, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kYellow)),
        ],
      ),
    );
  }
}
