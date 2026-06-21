import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';

final workoutTemplatesProvider = StreamProvider<List<WorkoutTemplate>>((ref) {
  return ref.watch(firestoreServiceProvider).watchWorkoutTemplates();
});

final customWorkoutsProvider = StreamProvider.family<List<CustomWorkout>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).watchCustomWorkouts(uid);
});

final workoutSessionsProvider = StreamProvider.family<List<WorkoutSession>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).watchWorkoutSessions(uid);
});

// ── Active Workout ─────────────────────────────────────────────────────────

class ActiveExerciseState {
  final WorkoutExercise exercise;
  final List<CompletedSet> sets;
  final String? notes;

  ActiveExerciseState({
    required this.exercise,
    required this.sets,
    this.notes,
  });

  double get totalVolume => sets.fold(0.0, (sum, s) => sum + ((s.weight ?? 0) * s.reps));

  ActiveExerciseState copyWith({List<CompletedSet>? sets, String? notes}) => ActiveExerciseState(
    exercise: exercise,
    sets: sets ?? this.sets,
    notes: notes ?? this.notes,
  );
}

class ActiveWorkoutState {
  final String title;
  final String sourceType;
  final String? sourceId;
  final List<ActiveExerciseState> exercises;
  final DateTime startedAt;
  final String? notes;
  final bool isActive;

  ActiveWorkoutState({
    required this.title,
    required this.sourceType,
    this.sourceId,
    required this.exercises,
    required this.startedAt,
    this.notes,
    this.isActive = true,
  });

  ActiveWorkoutState copyWith({
    List<ActiveExerciseState>? exercises,
    String? notes,
    bool? isActive,
  }) => ActiveWorkoutState(
    title: title,
    sourceType: sourceType,
    sourceId: sourceId,
    exercises: exercises ?? this.exercises,
    startedAt: startedAt,
    notes: notes ?? this.notes,
    isActive: isActive ?? this.isActive,
  );
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState?> {
  ActiveWorkoutNotifier() : super(null);

  void startFromTemplate(WorkoutTemplate template) {
    state = ActiveWorkoutState(
      title: template.title,
      sourceType: 'template',
      sourceId: template.id,
      startedAt: DateTime.now(),
      exercises: template.exercises
          .map((e) => ActiveExerciseState(
                exercise: e,
                sets: List.generate(
                  e.sets,
                  (_) => CompletedSet(reps: e.reps, weight: e.weight, completed: false),
                ),
              ))
          .toList(),
    );
  }

  void startFromCustom(CustomWorkout workout) {
    state = ActiveWorkoutState(
      title: workout.title,
      sourceType: 'custom',
      sourceId: workout.id,
      startedAt: DateTime.now(),
      exercises: workout.exercises
          .map((e) => ActiveExerciseState(
                exercise: e,
                sets: List.generate(
                  e.sets,
                  (_) => CompletedSet(reps: e.reps, weight: e.weight, completed: false),
                ),
              ))
          .toList(),
    );
  }

  void startQuick(String title) {
    state = ActiveWorkoutState(
      title: title,
      sourceType: 'quickStart',
      startedAt: DateTime.now(),
      exercises: [],
    );
  }

  void addExercise(WorkoutExercise exercise) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      exercises: [
        ...current.exercises,
        ActiveExerciseState(
          exercise: exercise,
          sets: List.generate(
            exercise.sets,
            (_) => CompletedSet(reps: exercise.reps, weight: exercise.weight, completed: false),
          ),
        ),
      ],
    );
  }

  void updateSet(int exerciseIndex, int setIndex, CompletedSet updatedSet) {
    final current = state;
    if (current == null) return;
    final exercises = List<ActiveExerciseState>.from(current.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<CompletedSet>.from(exercise.sets);
    sets[setIndex] = updatedSet;
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = current.copyWith(exercises: exercises);
  }

  void addSet(int exerciseIndex) {
    final current = state;
    if (current == null) return;
    final exercises = List<ActiveExerciseState>.from(current.exercises);
    final exercise = exercises[exerciseIndex];
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : const CompletedSet(reps: 10);
    exercises[exerciseIndex] = exercise.copyWith(
      sets: [...exercise.sets, CompletedSet(reps: lastSet.reps, weight: lastSet.weight, completed: false)],
    );
    state = current.copyWith(exercises: exercises);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    final current = state;
    if (current == null) return;
    final exercises = List<ActiveExerciseState>.from(current.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<CompletedSet>.from(exercise.sets)..removeAt(setIndex);
    exercises[exerciseIndex] = exercise.copyWith(sets: sets);
    state = current.copyWith(exercises: exercises);
  }

  void updateExerciseNotes(int exerciseIndex, String notes) {
    final current = state;
    if (current == null) return;
    final exercises = List<ActiveExerciseState>.from(current.exercises);
    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(notes: notes);
    state = current.copyWith(exercises: exercises);
  }

  void updateWorkoutNotes(String notes) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(notes: notes);
  }

  void cancel() => state = null;
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState?>((ref) {
  return ActiveWorkoutNotifier();
});
