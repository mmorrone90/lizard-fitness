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
                        FilterChip(
                          label: const Text('All'),
                          selected: muscleFilter == null,
                          onSelected: (_) => ref.read(exerciseMuscleFilterProvider.notifier).state = null,
                        ),
                        const SizedBox(width: 6),
                        ...MuscleGroup.values.map((m) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(m.label),
                            selected: muscleFilter == m,
                            onSelected: (_) => ref.read(exerciseMuscleFilterProvider.notifier).state = muscleFilter == m ? null : m,
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
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
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
    return GestureDetector(
      onTap: () => context.push('/exercises/${exercise.id}'),
      child: Container(
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
              child: Center(child: Text(exercise.primaryMuscle.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(exercise.primaryMuscle.label, style: Theme.of(context).textTheme.bodySmall),
                      Text(' · ', style: Theme.of(context).textTheme.bodySmall),
                      Text(exercise.difficulty.label, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextMuted, size: 20),
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
