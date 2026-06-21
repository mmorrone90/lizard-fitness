import 'package:cloud_firestore/cloud_firestore.dart';

enum MuscleGroup {
  chest, back, shoulders, biceps, triceps, forearms,
  quads, hamstrings, glutes, calves, core, fullBody, cardio
}

extension MuscleGroupExt on MuscleGroup {
  String get label => switch (this) {
    MuscleGroup.chest => 'Chest',
    MuscleGroup.back => 'Back',
    MuscleGroup.shoulders => 'Shoulders',
    MuscleGroup.biceps => 'Biceps',
    MuscleGroup.triceps => 'Triceps',
    MuscleGroup.forearms => 'Forearms',
    MuscleGroup.quads => 'Quads',
    MuscleGroup.hamstrings => 'Hamstrings',
    MuscleGroup.glutes => 'Glutes',
    MuscleGroup.calves => 'Calves',
    MuscleGroup.core => 'Core',
    MuscleGroup.fullBody => 'Full Body',
    MuscleGroup.cardio => 'Cardio',
  };

  String get emoji => switch (this) {
    MuscleGroup.chest => '🫁',
    MuscleGroup.back => '🔙',
    MuscleGroup.shoulders => '🤷',
    MuscleGroup.biceps => '💪',
    MuscleGroup.triceps => '💪',
    MuscleGroup.forearms => '🤜',
    MuscleGroup.quads => '🦵',
    MuscleGroup.hamstrings => '🦵',
    MuscleGroup.glutes => '🍑',
    MuscleGroup.calves => '🦵',
    MuscleGroup.core => '⚡',
    MuscleGroup.fullBody => '🏋️',
    MuscleGroup.cardio => '❤️',
  };
}

enum EquipmentType {
  barbell, dumbbell, machine, cable, bodyweight, kettlebell, bands, pullupBar, bench
}

extension EquipmentTypeExt on EquipmentType {
  String get label => switch (this) {
    EquipmentType.barbell => 'Barbell',
    EquipmentType.dumbbell => 'Dumbbell',
    EquipmentType.machine => 'Machine',
    EquipmentType.cable => 'Cable',
    EquipmentType.bodyweight => 'Bodyweight',
    EquipmentType.kettlebell => 'Kettlebell',
    EquipmentType.bands => 'Resistance Bands',
    EquipmentType.pullupBar => 'Pull-up Bar',
    EquipmentType.bench => 'Bench',
  };
}

enum DifficultyLevel { beginner, intermediate, advanced }

extension DifficultyLevelExt on DifficultyLevel {
  String get label => switch (this) {
    DifficultyLevel.beginner => 'Beginner',
    DifficultyLevel.intermediate => 'Intermediate',
    DifficultyLevel.advanced => 'Advanced',
  };
}

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final List<EquipmentType> equipment;
  final DifficultyLevel difficulty;
  final List<String> instructions;
  final List<String> formTips;
  final List<String> safetyTips;
  final List<String> commonMistakes;
  final String? videoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.formTips,
    required this.safetyTips,
    required this.commonMistakes,
    this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exercise.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Exercise(
      id: doc.id,
      name: d['name'] ?? '',
      primaryMuscle: MuscleGroup.values.firstWhere(
        (e) => e.name == d['primaryMuscle'],
        orElse: () => MuscleGroup.fullBody,
      ),
      secondaryMuscles: (d['secondaryMuscles'] as List<dynamic>? ?? [])
          .map((m) => MuscleGroup.values.firstWhere(
                (e) => e.name == m,
                orElse: () => MuscleGroup.fullBody,
              ))
          .toList(),
      equipment: (d['equipment'] as List<dynamic>? ?? [])
          .map((eq) => EquipmentType.values.firstWhere(
                (e) => e.name == eq,
                orElse: () => EquipmentType.bodyweight,
              ))
          .toList(),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == d['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      instructions: List<String>.from(d['instructions'] ?? []),
      formTips: List<String>.from(d['formTips'] ?? []),
      safetyTips: List<String>.from(d['safetyTips'] ?? []),
      commonMistakes: List<String>.from(d['commonMistakes'] ?? []),
      videoUrl: d['videoUrl'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'primaryMuscle': primaryMuscle.name,
    'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
    'equipment': equipment.map((e) => e.name).toList(),
    'difficulty': difficulty.name,
    'instructions': instructions,
    'formTips': formTips,
    'safetyTips': safetyTips,
    'commonMistakes': commonMistakes,
    'videoUrl': videoUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
