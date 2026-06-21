import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedSet {
  final int reps;
  final double? weight;
  final bool completed;
  final String? notes;

  const CompletedSet({
    required this.reps,
    this.weight,
    this.completed = true,
    this.notes,
  });

  factory CompletedSet.fromMap(Map<String, dynamic> d) => CompletedSet(
    reps: d['reps'] ?? 0,
    weight: d['weight']?.toDouble(),
    completed: d['completed'] ?? true,
    notes: d['notes'],
  );

  Map<String, dynamic> toMap() => {
    'reps': reps,
    'weight': weight,
    'completed': completed,
    'notes': notes,
  };

  CompletedSet copyWith({int? reps, double? weight, bool? completed, String? notes}) =>
    CompletedSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
}

class CompletedExercise {
  final String exerciseId;
  final String exerciseName;
  final List<CompletedSet> sets;
  final String? notes;

  const CompletedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    this.notes,
  });

  double get totalVolume => sets
      .where((s) => s.completed)
      .fold(0.0, (sum, s) => sum + ((s.weight ?? 0) * s.reps));

  int get completedSets => sets.where((s) => s.completed).length;

  factory CompletedExercise.fromMap(Map<String, dynamic> d) => CompletedExercise(
    exerciseId: d['exerciseId'] ?? '',
    exerciseName: d['exerciseName'] ?? '',
    sets: (d['sets'] as List<dynamic>? ?? [])
        .map((s) => CompletedSet.fromMap(s as Map<String, dynamic>))
        .toList(),
    notes: d['notes'],
  );

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'sets': sets.map((s) => s.toMap()).toList(),
    'notes': notes,
  };
}

class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final String recordType;
  final double value;
  final String unit;

  const PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.recordType,
    required this.value,
    required this.unit,
  });

  factory PersonalRecord.fromMap(Map<String, dynamic> d) => PersonalRecord(
    exerciseId: d['exerciseId'] ?? '',
    exerciseName: d['exerciseName'] ?? '',
    recordType: d['recordType'] ?? 'weight',
    value: (d['value'] ?? 0).toDouble(),
    unit: d['unit'] ?? 'kg',
  );

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'recordType': recordType,
    'value': value,
    'unit': unit,
  };
}

class WorkoutSession {
  final String id;
  final String userId;
  final String? sourceWorkoutId;
  final String sourceType;
  final String workoutTitle;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? duration;
  final List<CompletedExercise> completedExercises;
  final double totalVolume;
  final List<PersonalRecord> personalRecords;
  final String? notes;
  final DateTime createdAt;

  const WorkoutSession({
    required this.id,
    required this.userId,
    this.sourceWorkoutId,
    required this.sourceType,
    required this.workoutTitle,
    required this.startedAt,
    this.completedAt,
    this.duration,
    required this.completedExercises,
    required this.totalVolume,
    required this.personalRecords,
    this.notes,
    required this.createdAt,
  });

  factory WorkoutSession.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkoutSession(
      id: doc.id,
      userId: d['userId'] ?? '',
      sourceWorkoutId: d['sourceWorkoutId'],
      sourceType: d['sourceType'] ?? 'quickStart',
      workoutTitle: d['workoutTitle'] ?? '',
      startedAt: (d['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (d['completedAt'] as Timestamp?)?.toDate(),
      duration: d['duration'],
      completedExercises: (d['completedExercises'] as List<dynamic>? ?? [])
          .map((e) => CompletedExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalVolume: (d['totalVolume'] ?? 0).toDouble(),
      personalRecords: (d['personalRecords'] as List<dynamic>? ?? [])
          .map((r) => PersonalRecord.fromMap(r as Map<String, dynamic>))
          .toList(),
      notes: d['notes'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'sourceWorkoutId': sourceWorkoutId,
    'sourceType': sourceType,
    'workoutTitle': workoutTitle,
    'startedAt': Timestamp.fromDate(startedAt),
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'duration': duration,
    'completedExercises': completedExercises.map((e) => e.toMap()).toList(),
    'totalVolume': totalVolume,
    'personalRecords': personalRecords.map((r) => r.toMap()).toList(),
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
