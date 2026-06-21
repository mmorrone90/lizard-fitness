import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

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
                const SizedBox(height: 24),
                _Section(
                  title: 'How to do it',
                  items: exercise.instructions,
                  numbered: true,
                ),
                if (exercise.formTips.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Section(title: 'Form Tips', items: exercise.formTips, icon: Icons.tips_and_updates_outlined, iconColor: kYellow),
                ],
                if (exercise.safetyTips.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Section(title: 'Safety Tips', items: exercise.safetyTips, icon: Icons.shield_outlined, iconColor: kSuccess),
                ],
                if (exercise.commonMistakes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Section(title: 'Common Mistakes', items: exercise.commonMistakes, icon: Icons.warning_amber_outlined, iconColor: kError),
                ],
                if (exercise.secondaryMuscles.isNotEmpty) ...[
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

class _Section extends StatelessWidget {
  final String title;
  final List<String> items;
  final bool numbered;
  final IconData? icon;
  final Color? iconColor;

  const _Section({
    required this.title,
    required this.items,
    this.numbered = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 10),
        ...items.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: numbered
                    ? Text('${e.key + 1}.', style: const TextStyle(color: kYellow, fontWeight: FontWeight.w700))
                    : const Icon(Icons.circle, size: 6, color: kYellow),
              ),
              Expanded(child: Text(e.value, style: Theme.of(context).textTheme.bodyLarge)),
            ],
          ),
        )),
      ],
    );
  }
}
