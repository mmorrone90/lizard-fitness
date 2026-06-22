import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/providers/exercise_provider.dart';
import 'package:lizard_fitness/providers/workout_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

/// 0 = Presets (workout templates), 1 = Library (single exercises).
final exercisesSegmentProvider = StateProvider<int>((ref) => 0);

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segment = ref.watch(exercisesSegmentProvider);
    final isLibrary = segment == 1;

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
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
                  const SizedBox(height: 14),
                  _SegmentToggle(
                    segment: segment,
                    onChanged: (s) => ref.read(exercisesSegmentProvider.notifier).state = s,
                  ),
                  if (isLibrary) ...[
                    const SizedBox(height: 12),
                    _LibraryFilters(),
                  ],
                ],
              ),
            ),
            Expanded(child: isLibrary ? _LibraryList() : _PresetsList()),
          ],
        ),
      ),
    );
  }
}

class _SegmentToggle extends StatelessWidget {
  final int segment;
  final ValueChanged<int> onChanged;
  const _SegmentToggle({required this.segment, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _seg(context, 'Presets', 0),
          _seg(context, 'Library', 1),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String label, int value) {
    final selected = segment == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? kYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? kBlack : kTextMuted,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(workoutTemplatesProvider);
    return templates.when(
      data: (list) => list.isEmpty
          ? _EmptyState(message: 'No presets yet')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: list.length,
              itemBuilder: (_, i) => _PresetCard(template: list[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: kYellow)),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _PresetCard extends ConsumerWidget {
  final WorkoutTemplate template;
  const _PresetCard({required this.template});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardLight.withOpacity(0.6)),
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
                child: Text(template.difficulty.label,
                  style: const TextStyle(color: kYellow, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(template.description, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
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

class _LibraryFilters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(exerciseSearchProvider);
    final muscleFilter = ref.watch(exerciseMuscleFilterProvider);
    return Column(
      children: [
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
    );
  }
}

class _LibraryList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredExercisesProvider);
    return filtered.when(
      data: (list) => list.isEmpty
          ? _EmptyState(message: 'No exercises found')
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: kCardLight.withOpacity(0.4), indent: 62),
              itemBuilder: (_, i) => _ExerciseRow(exercise: list[i]),
            ),
      loading: () => const Center(child: CircularProgressIndicator(color: kYellow)),
      error: (e, _) => Center(child: Text('Error: $e')),
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
  final String message;
  const _EmptyState({this.message = 'No exercises found'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: kTextMuted, size: 48),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Try a different search or filter', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
