import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/providers/workout_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;
  int? _restCountdown;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() => _restCountdown = seconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_restCountdown == null || _restCountdown! <= 0) {
        _restTimer?.cancel();
        setState(() => _restCountdown = null);
      } else {
        setState(() => _restCountdown = _restCountdown! - 1);
      }
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _finishWorkout() async {
    final workout = ref.read(activeWorkoutProvider);
    if (workout == null) return;

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final completedExercises = workout.exercises.map((e) => CompletedExercise(
      exerciseId: e.exercise.exerciseId,
      exerciseName: e.exercise.exerciseName,
      sets: e.sets,
      notes: e.notes,
    )).toList();

    final totalVolume = completedExercises.fold(0.0, (sum, e) => sum + e.totalVolume);
    final now = DateTime.now();

    final session = WorkoutSession(
      id: '',
      userId: uid,
      sourceWorkoutId: workout.sourceId,
      sourceType: workout.sourceType,
      workoutTitle: workout.title,
      startedAt: workout.startedAt,
      completedAt: now,
      duration: _elapsedSeconds ~/ 60,
      completedExercises: completedExercises,
      totalVolume: totalVolume,
      personalRecords: [],
      notes: workout.notes,
      createdAt: now,
    );

    final savedId = await ref.read(firestoreServiceProvider).saveWorkoutSession(session);
    final saved = WorkoutSession(
      id: savedId,
      userId: session.userId,
      sourceWorkoutId: session.sourceWorkoutId,
      sourceType: session.sourceType,
      workoutTitle: session.workoutTitle,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      duration: session.duration,
      completedExercises: session.completedExercises,
      totalVolume: session.totalVolume,
      personalRecords: session.personalRecords,
      notes: session.notes,
      createdAt: session.createdAt,
    );

    ref.read(activeWorkoutProvider.notifier).cancel();
    if (mounted) context.pushReplacement('/workout/complete', extra: saved);
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(activeWorkoutProvider);
    if (workout == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/workout'));
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kYellow)));
    }

    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        title: Text(workout.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(_formatDuration(_elapsedSeconds),
                style: const TextStyle(color: kYellow, fontWeight: FontWeight.w700, fontSize: 18)),
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: Column(
        children: [
          if (_restCountdown != null) _buildRestBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workout.exercises.length,
              itemBuilder: (_, i) => _ExerciseCard(
                exerciseState: workout.exercises[i],
                exerciseIndex: i,
                onSetToggle: (setIdx, set) {
                  ref.read(activeWorkoutProvider.notifier).updateSet(i, setIdx, set);
                  if (set.completed && workout.exercises[i].exercise.restSeconds > 0) {
                    _startRest(workout.exercises[i].exercise.restSeconds);
                  }
                },
                onAddSet: () => ref.read(activeWorkoutProvider.notifier).addSet(i),
                onRemoveSet: (setIdx) => ref.read(activeWorkoutProvider.notifier).removeSet(i, setIdx),
              ),
            ),
          ),
          _buildFinishButton(),
        ],
      ),
    );
  }

  Widget _buildRestBanner() {
    return Container(
      color: kYellow.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.timer, color: kYellow, size: 18),
          const SizedBox(width: 8),
          Text('Rest: ${_formatDuration(_restCountdown!)}',
            style: const TextStyle(color: kYellow, fontWeight: FontWeight.w700)),
          const Spacer(),
          TextButton(
            onPressed: () {
              _restTimer?.cancel();
              setState(() => _restCountdown = null);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _finishWorkout,
        icon: const Icon(Icons.check),
        label: const Text('FINISH WORKOUT'),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        title: const Text('Cancel workout?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep going')),
          TextButton(
            onPressed: () {
              ref.read(activeWorkoutProvider.notifier).cancel();
              Navigator.pop(context);
              context.go('/workout');
            },
            child: const Text('Cancel workout', style: TextStyle(color: kError)),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final ActiveExerciseState exerciseState;
  final int exerciseIndex;
  final void Function(int, CompletedSet) onSetToggle;
  final VoidCallback onAddSet;
  final void Function(int) onRemoveSet;

  const _ExerciseCard({
    required this.exerciseState,
    required this.exerciseIndex,
    required this.onSetToggle,
    required this.onAddSet,
    required this.onRemoveSet,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    final ex = widget.exerciseState;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(ex.exercise.exerciseName, style: Theme.of(context).textTheme.headlineSmall),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(width: 32, child: Text('SET', style: TextStyle(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                SizedBox(width: 8),
                Expanded(child: Text('KG', style: TextStyle(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                SizedBox(width: 8),
                SizedBox(width: 60, child: Text('REPS', style: TextStyle(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700))),
                SizedBox(width: 8),
                SizedBox(width: 44, child: Text('DONE', style: TextStyle(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...ex.sets.asMap().entries.map((entry) {
            final i = entry.key;
            final set = entry.value;
            return _SetRow(
              setNumber: i + 1,
              set: set,
              onToggle: () => widget.onSetToggle(i, set.copyWith(completed: !set.completed)),
              onWeightChanged: (w) => widget.onSetToggle(i, set.copyWith(weight: w)),
              onRepsChanged: (r) => widget.onSetToggle(i, set.copyWith(reps: r)),
              onRemove: ex.sets.length > 1 ? () => widget.onRemoveSet(i) : null,
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextButton.icon(
              onPressed: widget.onAddSet,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatefulWidget {
  final int setNumber;
  final CompletedSet set;
  final VoidCallback onToggle;
  final void Function(double) onWeightChanged;
  final void Function(int) onRepsChanged;
  final VoidCallback? onRemove;

  const _SetRow({
    required this.setNumber,
    required this.set,
    required this.onToggle,
    required this.onWeightChanged,
    required this.onRepsChanged,
    this.onRemove,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(text: widget.set.weight?.toString() ?? '');
    _repsCtrl = TextEditingController(text: widget.set.reps.toString());
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.set.completed;

    return GestureDetector(
      onLongPress: widget.onRemove,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        color: completed ? kYellow.withOpacity(0.05) : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.setNumber}',
                style: TextStyle(
                  color: completed ? kYellow : kTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  fillColor: completed ? kYellow.withOpacity(0.1) : kCardLight,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: '0',
                ),
                onChanged: (v) {
                  final w = double.tryParse(v);
                  if (w != null) widget.onWeightChanged(w);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _repsCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  fillColor: completed ? kYellow.withOpacity(0.1) : kCardLight,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: '0',
                ),
                onChanged: (v) {
                  final r = int.tryParse(v);
                  if (r != null) widget.onRepsChanged(r);
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onToggle,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: completed ? kYellow : kCardLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.check,
                  color: completed ? kBlack : kTextMuted,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
