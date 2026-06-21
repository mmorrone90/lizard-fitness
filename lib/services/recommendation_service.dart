import 'package:lizard_fitness/models/onboarding_profile.dart';

class RecommendationService {
  static String recommendPlanType(OnboardingProfile profile) {
    final days = profile.trainingDaysPerWeek;
    final level = profile.experienceLevel;
    final goals = profile.goals;

    if (level == ExperienceLevel.beginner) {
      if (goals.contains(FitnessGoal.fatLoss) || goals.contains(FitnessGoal.hiit)) {
        return 'Full Body + Conditioning';
      }
      return 'Beginner Full Body';
    }

    if (level == ExperienceLevel.intermediate) {
      if (days <= 3) return 'Full Body';
      if (days == 4) return 'Upper/Lower Split';
      return 'Push/Pull/Legs';
    }

    // Advanced
    if (days <= 3) return 'Full Body';
    if (days == 4) return 'Upper/Lower Split';
    return 'Push/Pull/Legs';
  }

  static String getPlanDescription(OnboardingProfile profile) {
    final plan = profile.recommendedPlanType ?? recommendPlanType(profile);
    final goals = profile.goals;

    if (plan.contains('Beginner Full Body')) {
      return 'Perfect for starting out. You\'ll train your whole body each session with fundamental movements to build a strong foundation. Focus on form before weight.';
    }
    if (plan.contains('Full Body + Conditioning')) {
      return 'A full body plan combined with conditioning work. Great for burning fat while building functional strength.';
    }
    if (plan.contains('Upper/Lower')) {
      return 'Split your training into upper body and lower body days. Efficient and effective for intermediate lifters training 4 days a week.';
    }
    if (plan.contains('Push/Pull/Legs')) {
      return 'The classic advanced split. Push days (chest, shoulders, triceps), Pull days (back, biceps), and Leg days. Maximises recovery and volume.';
    }
    if (goals.contains(FitnessGoal.strength)) {
      return 'A strength-focused plan built around compound movements: squat, bench press, deadlift, and overhead press. Progressive overload is the key.';
    }
    return 'A personalised plan based on your goals and experience level.';
  }

  static List<String> getTrainingTips(OnboardingProfile profile) {
    final level = profile.experienceLevel;
    final tips = <String>[];

    if (level == ExperienceLevel.beginner) {
      tips.addAll([
        'Focus on learning proper form before adding weight',
        'Aim for consistency — 3 sessions per week beats 6 inconsistent ones',
        'Progressive overload: try to add a little more each week',
        'Rest is when you grow — don\'t skip recovery days',
        'Protein is key: aim for ~0.8-1g per pound of bodyweight',
      ]);
    } else if (level == ExperienceLevel.intermediate) {
      tips.addAll([
        'Track your lifts to ensure progressive overload',
        'Deload every 4-6 weeks to let your body recover fully',
        'Prioritise sleep — 7-9 hours optimises muscle growth and recovery',
        'Focus on the mind-muscle connection on isolation exercises',
      ]);
    } else {
      tips.addAll([
        'Periodisation is key — cycle between hypertrophy, strength, and deload phases',
        'Address weak points directly in your programming',
        'Mobility work prevents injury and improves performance',
        'Consider a coach or advanced programme for continued progress',
      ]);
    }

    return tips;
  }
}
