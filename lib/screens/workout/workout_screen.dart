import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/providers/workout_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/models/exercise.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final uid = auth.valueOrNull?.uid;
    final templates = ref.watch(workoutTemplatesProvider);
    final customWorkouts = uid != null ? ref.watch(customWorkoutsProvider(uid)) : null;
    final activeWorkout = ref.watch(activeWorkoutProvider);

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Text('Workout', style: Theme.of(context).textTheme.displaySmall),
              ),
            ),
            if (activeWorkout != null)
              SliverToBoxAdapter(child: _ActiveBanner(onResume: () => context.push('/workout/active'))),
            SliverToBoxAdapter(child: _QuickStartSection(uid: uid)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text('Workout Templates', style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            templates.when(
              data: (list) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _TemplateCard(template: list[i]),
                  ),
                  childCount: list.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: kYellow))),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
            ),
            if (uid != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Workouts', style: Theme.of(context).textTheme.headlineSmall),
                      TextButton.icon(
                        onPressed: () => context.push('/exercises/builder/new'),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('New'),
                      ),
                    ],
                  ),
                ),
              ),
              customWorkouts?.when(
                data: (list) => list.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _EmptyCustomWorkouts(onBuild: () => context.push('/exercises/builder/new')),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: _CustomWorkoutCard(workout: list[i]),
                          ),
                          childCount: list.length,
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
              ) ?? const SliverToBoxAdapter(child: SizedBox()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  final VoidCallback onResume;
  const _ActiveBanner({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kYellow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, color: kBlack, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Workout in progress — tap to resume',
                style: const TextStyle(color: kBlack, fontWeight: FontWeight.w700)),
            ),
            const Icon(Icons.arrow_forward_ios, color: kBlack, size: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickStartSection extends ConsumerWidget {
  final String? uid;
  const _QuickStartSection({this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(activeWorkoutProvider.notifier).startQuick('Quick Workout');
          context.push('/workout/active');
        },
        icon: const Icon(Icons.bolt),
        label: const Text('QUICK START'),
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
      ),
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  final WorkoutTemplate template;
  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(template.title, style: Theme.of(context).textTheme.headlineSmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  template.difficulty.label,
                  style: const TextStyle(color: kYellow, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(template.description, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: kTextMuted),
              const SizedBox(width: 4),
              Text('${template.estimatedDuration}min', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.fitness_center, size: 14, color: kTextMuted),
              const SizedBox(width: 4),
              Text('${template.exercises.length} exercises', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(activeWorkoutProvider.notifier).startFromTemplate(template);
                context.push('/workout/active');
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
              child: const Text('START'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomWorkoutCard extends ConsumerWidget {
  final CustomWorkout workout;
  const _CustomWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kCardLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('${workout.exercises.length} exercises', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).startFromCustom(workout);
              context.push('/workout/active');
            },
            child: const Text('START'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCustomWorkouts extends StatelessWidget {
  final VoidCallback onBuild;
  const _EmptyCustomWorkouts({required this.onBuild});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          const Icon(Icons.add_circle_outline, color: kTextMuted, size: 40),
          const SizedBox(height: 12),
          Text('No custom workouts yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Build a workout tailored to your goals', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onBuild,
            icon: const Icon(Icons.add),
            label: const Text('Build a workout'),
          ),
        ],
      ),
    );
  }
}
