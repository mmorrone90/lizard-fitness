import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/services/firestore_service.dart';
import 'package:lizard_fitness/services/recommendation_service.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';

final onboardingProfileProvider = FutureProvider.family<OnboardingProfile?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).getOnboardingProfile(uid);
});

class OnboardingNotifier extends StateNotifier<OnboardingProfile?> {
  OnboardingNotifier(this._service) : super(null);

  final FirestoreService _service;

  void update(OnboardingProfile profile) => state = profile;

  Future<void> save() async {
    final profile = state;
    if (profile == null) return;
    final plan = RecommendationService.recommendPlanType(profile);
    final updated = profile.copyWith(
      recommendedPlanType: plan,
      updatedAt: DateTime.now(),
    );
    state = updated;
    await _service.saveOnboardingProfile(updated);
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingProfile?>((ref) {
  return OnboardingNotifier(ref.watch(firestoreServiceProvider));
});
