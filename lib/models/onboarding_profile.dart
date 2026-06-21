import 'package:cloud_firestore/cloud_firestore.dart';

enum ExperienceLevel { beginner, intermediate, advanced }
enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive, extremelyActive }
enum GymAccess { fullGym, homeGym, bodyweightOnly }
enum FitnessGoal { muscleGain, fatLoss, strength, endurance, hiit, generalFitness, mobility }
enum Gender { male, female, other, preferNotToSay }
enum HeightUnit { cm, ft }
enum WeightUnit { kg, lb }

extension ExperienceLevelExt on ExperienceLevel {
  String get label => switch (this) {
    ExperienceLevel.beginner => 'Beginner',
    ExperienceLevel.intermediate => 'Intermediate',
    ExperienceLevel.advanced => 'Advanced',
  };
}

extension ActivityLevelExt on ActivityLevel {
  String get label => switch (this) {
    ActivityLevel.sedentary => 'Sedentary (little/no exercise)',
    ActivityLevel.lightlyActive => 'Lightly Active (1-3 days/week)',
    ActivityLevel.moderatelyActive => 'Moderately Active (3-5 days/week)',
    ActivityLevel.veryActive => 'Very Active (6-7 days/week)',
    ActivityLevel.extremelyActive => 'Extremely Active (athlete)',
  };
}

extension GymAccessExt on GymAccess {
  String get label => switch (this) {
    GymAccess.fullGym => 'Full Gym',
    GymAccess.homeGym => 'Home Gym',
    GymAccess.bodyweightOnly => 'Bodyweight Only',
  };
}

extension FitnessGoalExt on FitnessGoal {
  String get label => switch (this) {
    FitnessGoal.muscleGain => 'Muscle Gain',
    FitnessGoal.fatLoss => 'Fat Loss',
    FitnessGoal.strength => 'Strength',
    FitnessGoal.endurance => 'Endurance',
    FitnessGoal.hiit => 'HIIT / Conditioning',
    FitnessGoal.generalFitness => 'General Fitness',
    FitnessGoal.mobility => 'Mobility',
  };

  String get emoji => switch (this) {
    FitnessGoal.muscleGain => '💪',
    FitnessGoal.fatLoss => '🔥',
    FitnessGoal.strength => '🏋️',
    FitnessGoal.endurance => '🏃',
    FitnessGoal.hiit => '⚡',
    FitnessGoal.generalFitness => '🎯',
    FitnessGoal.mobility => '🧘',
  };
}

extension GenderExt on Gender {
  String get label => switch (this) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.other => 'Other',
    Gender.preferNotToSay => 'Prefer not to say',
  };
}

class OnboardingProfile {
  final String userId;
  final String name;
  final int age;
  final Gender gender;
  final double height;
  final double weight;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final ExperienceLevel experienceLevel;
  final ActivityLevel activityLevel;
  final String? injuries;
  final int trainingDaysPerWeek;
  final int preferredSessionDuration;
  final GymAccess gymAccess;
  final List<String> availableEquipment;
  final List<FitnessGoal> goals;
  final String? recommendedPlanType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OnboardingProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.heightUnit,
    required this.weightUnit,
    required this.experienceLevel,
    required this.activityLevel,
    this.injuries,
    required this.trainingDaysPerWeek,
    required this.preferredSessionDuration,
    required this.gymAccess,
    required this.availableEquipment,
    required this.goals,
    this.recommendedPlanType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnboardingProfile.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OnboardingProfile(
      userId: d['userId'] ?? doc.id,
      name: d['name'] ?? '',
      age: d['age'] ?? 0,
      gender: Gender.values.firstWhere(
        (e) => e.name == d['gender'],
        orElse: () => Gender.preferNotToSay,
      ),
      height: (d['height'] ?? 0).toDouble(),
      weight: (d['weight'] ?? 0).toDouble(),
      heightUnit: d['heightUnit'] == 'ft' ? HeightUnit.ft : HeightUnit.cm,
      weightUnit: d['weightUnit'] == 'lb' ? WeightUnit.lb : WeightUnit.kg,
      experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == d['experienceLevel'],
        orElse: () => ExperienceLevel.beginner,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == d['activityLevel'],
        orElse: () => ActivityLevel.sedentary,
      ),
      injuries: d['injuries'],
      trainingDaysPerWeek: d['trainingDaysPerWeek'] ?? 3,
      preferredSessionDuration: d['preferredSessionDuration'] ?? 45,
      gymAccess: GymAccess.values.firstWhere(
        (e) => e.name == d['gymAccess'],
        orElse: () => GymAccess.fullGym,
      ),
      availableEquipment: List<String>.from(d['availableEquipment'] ?? []),
      goals: (d['goals'] as List<dynamic>? ?? [])
          .map((g) => FitnessGoal.values.firstWhere(
                (e) => e.name == g,
                orElse: () => FitnessGoal.generalFitness,
              ))
          .toList(),
      recommendedPlanType: d['recommendedPlanType'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'age': age,
    'gender': gender.name,
    'height': height,
    'weight': weight,
    'heightUnit': heightUnit.name,
    'weightUnit': weightUnit.name,
    'experienceLevel': experienceLevel.name,
    'activityLevel': activityLevel.name,
    'injuries': injuries,
    'trainingDaysPerWeek': trainingDaysPerWeek,
    'preferredSessionDuration': preferredSessionDuration,
    'gymAccess': gymAccess.name,
    'availableEquipment': availableEquipment,
    'goals': goals.map((g) => g.name).toList(),
    'recommendedPlanType': recommendedPlanType,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  String get weightDisplay => weightUnit == WeightUnit.kg
      ? '${weight.toStringAsFixed(1)} kg'
      : '${weight.toStringAsFixed(1)} lb';

  String get heightDisplay => heightUnit == HeightUnit.cm
      ? '${height.toStringAsFixed(0)} cm'
      : '${height.toStringAsFixed(0)} ft';

  OnboardingProfile copyWith({
    String? name,
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    HeightUnit? heightUnit,
    WeightUnit? weightUnit,
    ExperienceLevel? experienceLevel,
    ActivityLevel? activityLevel,
    String? injuries,
    int? trainingDaysPerWeek,
    int? preferredSessionDuration,
    GymAccess? gymAccess,
    List<String>? availableEquipment,
    List<FitnessGoal>? goals,
    String? recommendedPlanType,
    DateTime? updatedAt,
  }) =>
      OnboardingProfile(
        userId: userId,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        height: height ?? this.height,
        weight: weight ?? this.weight,
        heightUnit: heightUnit ?? this.heightUnit,
        weightUnit: weightUnit ?? this.weightUnit,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        activityLevel: activityLevel ?? this.activityLevel,
        injuries: injuries ?? this.injuries,
        trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
        preferredSessionDuration: preferredSessionDuration ?? this.preferredSessionDuration,
        gymAccess: gymAccess ?? this.gymAccess,
        availableEquipment: availableEquipment ?? this.availableEquipment,
        goals: goals ?? this.goals,
        recommendedPlanType: recommendedPlanType ?? this.recommendedPlanType,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
