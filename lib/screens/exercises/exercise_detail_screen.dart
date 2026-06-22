import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/exercises/exercise_video.dart';

final _exerciseDetailProvider = FutureProvider.family<Exercise?, String>((ref, id) async {
  return ref.watch(firestoreServiceProvider).getExercise(id);
});

class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(_exerciseDetailProvider(exerciseId));

    return Scaffold(
      backgroundColor: kBlack,
      body: exercise.when(
        data: (ex) => ex == null
            ? const Center(child: Text('Exercise not found'))
            : _ExerciseDetail(exercise: ex),
        loading: () => const Center(child: CircularProgressIndicator(color: kYellow)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ExerciseDetail extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseDetail({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: kBlack,
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kYellow.withOpacity(0.15), kBlack],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Text(exercise.primaryMuscle.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TagRow(exercise: exercise),
                const SizedBox(height: 20),
                Text('How to perform', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                ExerciseVideo(url: exercise.videoUrl),
                if (exercise.secondaryMuscles.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const SizedBox(height: 20),
                  Text('Secondary Muscles', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: exercise.secondaryMuscles.map((m) => Chip(label: Text(m.label))).toList(),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  final Exercise exercise;
  const _TagRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Tag(label: exercise.primaryMuscle.label, color: kYellow),
        _Tag(label: exercise.difficulty.label),
        ...exercise.equipment.take(2).map((e) => _Tag(label: e.label)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, this.color = kTextSecondary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

