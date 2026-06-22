import 'package:flutter/material.dart';
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

  // kept for backward compat but prefer icon/color
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

  IconData get icon => switch (this) {
    MuscleGroup.chest       => Icons.fitness_center,
    MuscleGroup.back        => Icons.accessibility_new,
    MuscleGroup.shoulders   => Icons.sports_handball,
    MuscleGroup.biceps      => Icons.fitness_center,
    MuscleGroup.triceps     => Icons.fitness_center,
    MuscleGroup.forearms    => Icons.pan_tool_outlined,
    MuscleGroup.quads       => Icons.directions_run,
    MuscleGroup.hamstrings  => Icons.directions_walk,
    MuscleGroup.glutes      => Icons.directions_walk,
    MuscleGroup.calves      => Icons.directions_walk,
    MuscleGroup.core        => Icons.rotate_90_degrees_ccw,
    MuscleGroup.fullBody    => Icons.self_improvement,
    MuscleGroup.cardio      => Icons.favorite,
  };

  Color get color => switch (this) {
    MuscleGroup.chest       => const Color(0xFFEF5350),
    MuscleGroup.back        => const Color(0xFF42A5F5),
    MuscleGroup.shoulders   => const Color(0xFF26C6DA),
    MuscleGroup.biceps      => const Color(0xFF66BB6A),
    MuscleGroup.triceps     => const Color(0xFF9CCC65),
    MuscleGroup.forearms    => const Color(0xFFD4E157),
    MuscleGroup.quads       => const Color(0xFFAB47BC),
    MuscleGroup.hamstrings  => const Color(0xFF7E57C2),
    MuscleGroup.glutes      => const Color(0xFFEC407A),
    MuscleGroup.calves      => const Color(0xFF26A69A),
    MuscleGroup.core        => const Color(0xFFFFD600),
    MuscleGroup.fullBody    => const Color(0xFFFFFFFF),
    MuscleGroup.cardio      => const Color(0xFFFF7043),
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
