import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/providers/workout_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class TodayWorkoutCard extends ConsumerWidget {
  final OnboardingProfile? profile;
  final List<WorkoutTemplate> templates;

  const TodayWorkoutCard({super.key, this.profile, required this.templates});

  WorkoutTemplate? _suggestedTemplate() {
    if (templates.isEmpty) return null;
    final plan = profile?.recommendedPlanType ?? '';
    if (plan.contains('Beginner')) {
      return templates.where((t) => t.difficulty == DifficultyLevel.beginner).firstOrNull;
    }
    if (plan.contains('Upper/Lower')) {
      return templates.where((t) => t.planType.contains('Upper/Lower')).firstOrNull;
    }
    if (plan.contains('Push/Pull/Legs')) {
      return templates.where((t) => t.planType.contains('Push')).firstOrNull;
    }
    return templates.firstOrNull;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = _suggestedTemplate();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kYellow.withOpacity(0.15), kYellow.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kYellow.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: kYellow, size: 18),
              const SizedBox(width: 6),
              Text("TODAY'S WORKOUT", style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: kYellow, letterSpacing: 1,
              )),
            ],
          ),
          const SizedBox(height: 12),
          if (template != null) ...[
            Text(template.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              '${template.exercises.length} exercises · ~${template.estimatedDuration}min',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(activeWorkoutProvider.notifier).startFromTemplate(template);
                  context.push('/workout/active');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('START WORKOUT'),
              ),
            ),
          ] else ...[
            Text('Ready to train?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Start a quick workout or choose from templates', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/workout'),
                icon: const Icon(Icons.fitness_center),
                label: const Text('START TRAINING'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
