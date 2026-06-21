import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/providers/exercise_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/common/lf_text_field.dart';
class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  final CustomWorkout? existingWorkout;
  const WorkoutBuilderScreen({super.key, this.existingWorkout});

  @override
  ConsumerState<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  FitnessGoal? _goal;
  DifficultyLevel? _difficulty;
  late List<WorkoutExercise> _exercises;

  @override
  void initState() {
    super.initState();
    final w = widget.existingWorkout;
    _titleCtrl = TextEditingController(text: w?.title ?? '');
    _descCtrl = TextEditingController(text: w?.description ?? '');
    _goal = w?.goal;
    _difficulty = w?.difficulty;
    _exercises = List.from(w?.exercises ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a workout title'), backgroundColor: kError),
      );
      return;
    }

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final workout = CustomWorkout(
      id: widget.existingWorkout?.id ?? '',
      userId: uid,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      goal: _goal,
      difficulty: _difficulty,
      targetMuscles: _exercises.map((e) => e.primaryMuscle).whereType<MuscleGroup>().toSet().toList(),
      exercises: _exercises,
      estimatedDuration: _exercises.fold<int>(0, (sum, e) => sum + (e.sets * (e.restSeconds + 45) ~/ 60)),
      createdAt: widget.existingWorkout?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(firestoreServiceProvider).saveCustomWorkout(workout);
    if (mounted) context.pop();
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ExercisePickerSheet(
        onAdd: (exercise) {
          setState(() => _exercises.add(WorkoutExercise(
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            primaryMuscle: exercise.primaryMuscle,
            sets: 3,
            reps: 10,
            restSeconds: 90,
          )));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        title: Text(widget.existingWorkout == null ? 'Build Workout' : 'Edit Workout'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save', style: TextStyle(color: kYellow))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LFTextField(controller: _titleCtrl, label: 'Workout title'),
          const SizedBox(height: 12),
          LFTextField(controller: _descCtrl, label: 'Description (optional)', maxLines: 2),
          const SizedBox(height: 20),
          Text('Goal', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FitnessGoal.values.map((g) => ChoiceChip(
              label: Text('${g.emoji} ${g.label}'),
              selected: _goal == g,
              onSelected: (_) => setState(() => _goal = _goal == g ? null : g),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Text('Difficulty', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: DifficultyLevel.values.map((d) => ChoiceChip(
              label: Text(d.label),
              selected: _difficulty == d,
              onSelected: (_) => setState(() => _difficulty = _difficulty == d ? null : d),
            )).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Exercises', style: Theme.of(context).textTheme.headlineSmall),
              TextButton.icon(
                onPressed: _showExercisePicker,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Icon(Icons.add_circle_outline, color: kTextMuted, size: 32),
                  const SizedBox(height: 8),
                  Text('No exercises yet', style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(onPressed: _showExercisePicker, child: const Text('Add exercises')),
                ],
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exercises.length,
              onReorder: (old, nw) {
                setState(() {
                  final item = _exercises.removeAt(old);
                  _exercises.insert(nw > old ? nw - 1 : nw, item);
                });
              },
              itemBuilder: (_, i) => _ExerciseBuilderRow(
                key: ValueKey('ex_$i'),
                exercise: _exercises[i],
                onRemove: () => setState(() => _exercises.removeAt(i)),
                onUpdate: (ex) => setState(() => _exercises[i] = ex),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        backgroundColor: kYellow,
        foregroundColor: kBlack,
        icon: const Icon(Icons.check),
        label: const Text('Save Workout', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ExerciseBuilderRow extends StatelessWidget {
  final WorkoutExercise exercise;
  final VoidCallback onRemove;
  final void Function(WorkoutExercise) onUpdate;

  const _ExerciseBuilderRow({
    super.key,
    required this.exercise,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, color: kTextMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.exerciseName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _SmallCounter(
                      label: 'Sets',
                      value: exercise.sets,
                      onDec: exercise.sets > 1 ? () => onUpdate(exercise.copyWith(sets: exercise.sets - 1)) : null,
                      onInc: () => onUpdate(exercise.copyWith(sets: exercise.sets + 1)),
                    ),
                    const SizedBox(width: 12),
                    _SmallCounter(
                      label: 'Reps',
                      value: exercise.reps,
                      onDec: exercise.reps > 1 ? () => onUpdate(exercise.copyWith(reps: exercise.reps - 1)) : null,
                      onInc: () => onUpdate(exercise.copyWith(reps: exercise.reps + 1)),
                    ),
                    const SizedBox(width: 12),
                    _SmallCounter(
                      label: 'Rest',
                      value: exercise.restSeconds,
                      step: 15,
                      suffix: 's',
                      onDec: exercise.restSeconds > 15 ? () => onUpdate(exercise.copyWith(restSeconds: exercise.restSeconds - 15)) : null,
                      onInc: () => onUpdate(exercise.copyWith(restSeconds: exercise.restSeconds + 15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kError, size: 20),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _SmallCounter extends StatelessWidget {
  final String label;
  final int value;
  final int step;
  final String suffix;
  final VoidCallback? onDec;
  final VoidCallback onInc;

  const _SmallCounter({
    required this.label,
    required this.value,
    this.step = 1,
    this.suffix = '',
    this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: kTextMuted, fontSize: 10)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onDec,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: kCardLight, borderRadius: BorderRadius.circular(4)),
                child: Icon(Icons.remove, size: 14, color: onDec != null ? kTextPrimary : kTextMuted),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('$value$suffix', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            GestureDetector(
              onTap: onInc,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(color: kCardLight, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.add, size: 14, color: kTextPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExercisePickerSheet extends ConsumerWidget {
  final void Function(Exercise) onAdd;
  const _ExercisePickerSheet({required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: kCardLight, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Add Exercise', style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: exercises.when(
              data: (list) => ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) => ListTile(
                  leading: Text(list[i].primaryMuscle.emoji, style: const TextStyle(fontSize: 24)),
                  title: Text(list[i].name, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(list[i].primaryMuscle.label, style: Theme.of(context).textTheme.bodySmall),
                  onTap: () {
                    onAdd(list[i]);
                    Navigator.pop(context);
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color: kYellow)),
              error: (_, __) => const Center(child: Text('Error loading exercises')),
            ),
          ),
        ],
      ),
    );
  }
}
