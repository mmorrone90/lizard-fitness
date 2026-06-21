import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/models/exercise.dart';

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final MuscleGroup? primaryMuscle;
  final int sets;
  final int reps;
  final double? weight;
  final int restSeconds;
  final String? notes;

  const WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    this.primaryMuscle,
    required this.sets,
    required this.reps,
    this.weight,
    this.restSeconds = 90,
    this.notes,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> d) => WorkoutExercise(
    exerciseId: d['exerciseId'] ?? '',
    exerciseName: d['exerciseName'] ?? '',
    primaryMuscle: d['primaryMuscle'] != null
        ? MuscleGroup.values.firstWhere(
            (e) => e.name == d['primaryMuscle'],
            orElse: () => MuscleGroup.fullBody,
          )
        : null,
    sets: d['sets'] ?? 3,
    reps: d['reps'] ?? 10,
    weight: d['weight']?.toDouble(),
    restSeconds: d['restSeconds'] ?? 90,
    notes: d['notes'],
  );

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'primaryMuscle': primaryMuscle?.name,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'restSeconds': restSeconds,
    'notes': notes,
  };

  WorkoutExercise copyWith({
    int? sets, int? reps, double? weight, int? restSeconds, String? notes,
  }) => WorkoutExercise(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    primaryMuscle: primaryMuscle,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    weight: weight ?? this.weight,
    restSeconds: restSeconds ?? this.restSeconds,
    notes: notes ?? this.notes,
  );
}

class WorkoutTemplate {
  final String id;
  final String title;
  final String description;
  final String planType;
  final FitnessGoal goal;
  final DifficultyLevel difficulty;
  final List<MuscleGroup> targetMuscles;
  final List<String> equipment;
  final int estimatedDuration;
  final List<String> recommendedFor;
  final List<WorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkoutTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.planType,
    required this.goal,
    required this.difficulty,
    required this.targetMuscles,
    required this.equipment,
    required this.estimatedDuration,
    required this.recommendedFor,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkoutTemplate.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkoutTemplate(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      planType: d['planType'] ?? '',
      goal: FitnessGoal.values.firstWhere(
        (e) => e.name == d['goal'],
        orElse: () => FitnessGoal.generalFitness,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == d['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      targetMuscles: (d['targetMuscles'] as List<dynamic>? ?? [])
          .map((m) => MuscleGroup.values.firstWhere(
                (e) => e.name == m,
                orElse: () => MuscleGroup.fullBody,
              ))
          .toList(),
      equipment: List<String>.from(d['equipment'] ?? []),
      estimatedDuration: d['estimatedDuration'] ?? 45,
      recommendedFor: List<String>.from(d['recommendedFor'] ?? []),
      exercises: (d['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CustomWorkout {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final FitnessGoal? goal;
  final DifficultyLevel? difficulty;
  final List<MuscleGroup> targetMuscles;
  final List<WorkoutExercise> exercises;
  final int? estimatedDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomWorkout({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.goal,
    this.difficulty,
    required this.targetMuscles,
    required this.exercises,
    this.estimatedDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomWorkout.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CustomWorkout(
      id: doc.id,
      userId: d['userId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'],
      goal: d['goal'] != null
          ? FitnessGoal.values.firstWhere(
              (e) => e.name == d['goal'],
              orElse: () => FitnessGoal.generalFitness,
            )
          : null,
      difficulty: d['difficulty'] != null
          ? DifficultyLevel.values.firstWhere(
              (e) => e.name == d['difficulty'],
              orElse: () => DifficultyLevel.beginner,
            )
          : null,
      targetMuscles: (d['targetMuscles'] as List<dynamic>? ?? [])
          .map((m) => MuscleGroup.values.firstWhere(
                (e) => e.name == m,
                orElse: () => MuscleGroup.fullBody,
              ))
          .toList(),
      exercises: (d['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      estimatedDuration: d['estimatedDuration'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'description': description,
    'goal': goal?.name,
    'difficulty': difficulty?.name,
    'targetMuscles': targetMuscles.map((m) => m.name).toList(),
    'exercises': exercises.map((e) => e.toMap()).toList(),
    'estimatedDuration': estimatedDuration,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
