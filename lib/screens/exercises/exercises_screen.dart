import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/providers/exercise_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredExercisesProvider);
    final search = ref.watch(exerciseSearchProvider);
    final muscleFilter = ref.watch(exerciseMuscleFilterProvider);

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Exercises', style: Theme.of(context).textTheme.displaySmall),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/exercises/builder/new'),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Build'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => ref.read(exerciseSearchProvider.notifier).state = v,
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => ref.read(exerciseSearchProvider.notifier).state = '',
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _MuscleChip(
                          label: 'All',
                          selected: muscleFilter == null,
                          color: kYellow,
                          onTap: () => ref.read(exerciseMuscleFilterProvider.notifier).state = null,
                        ),
                        const SizedBox(width: 6),
                        ...MuscleGroup.values.map((m) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _MuscleChip(
                            label: m.label,
                            color: m.color,
                            selected: muscleFilter == m,
                            onTap: () => ref.read(exerciseMuscleFilterProvider.notifier).state = muscleFilter == m ? null : m,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.when(
                data: (list) => list.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: kCardLight.withOpacity(0.4), indent: 62),
                        itemBuilder: (_, i) => _ExerciseRow(exercise: list[i]),
                      ),
                loading: () => const Center(child: CircularProgressIndicator(color: kYellow)),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final muscle = exercise.primaryMuscle;

    return InkWell(
      onTap: () => context.push('/exercises/${exercise.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Muscle icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: muscle.color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: muscle.color.withOpacity(0.25), width: 1.5),
              ),
              child: Icon(muscle.icon, color: muscle.color, size: 22),
            ),
            const SizedBox(width: 14),
            // Name + muscle subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(muscle.label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kTextMuted)),
                ],
              ),
            ),
            // Trailing trend circle
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kCardLight, width: 1.5),
              ),
              child: const Icon(Icons.trending_up, color: kTextSecondary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _MuscleChip({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.18) : kCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : kCardLight, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? color : kTextMuted,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: kTextMuted, size: 48),
          const SizedBox(height: 12),
          Text('No exercises found', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Try a different search or filter', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
