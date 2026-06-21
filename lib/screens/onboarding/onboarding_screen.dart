import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/providers/onboarding_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/onboarding/personal_details_step.dart';
import 'package:lizard_fitness/widgets/onboarding/fitness_profile_step.dart';
import 'package:lizard_fitness/widgets/onboarding/training_setup_step.dart';
import 'package:lizard_fitness/widgets/onboarding/goals_step.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form state
  final _nameCtrl = TextEditingController();
  int _age = 25;
  Gender _gender = Gender.preferNotToSay;
  double _height = 175;
  double _weight = 75;
  HeightUnit _heightUnit = HeightUnit.cm;
  WeightUnit _weightUnit = WeightUnit.kg;
  ExperienceLevel _experience = ExperienceLevel.beginner;
  ActivityLevel _activity = ActivityLevel.moderatelyActive;
  String _injuries = '';
  int _trainingDays = 3;
  int _sessionDuration = 45;
  GymAccess _gymAccess = GymAccess.fullGym;
  List<String> _equipment = [];
  List<FitnessGoal> _goals = [];

  final _titles = ['About You', 'Your Fitness', 'Training Setup', 'Your Goals'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<void> _finish() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final profile = OnboardingProfile(
      userId: user.uid,
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : user.displayName ?? 'Athlete',
      age: _age,
      gender: _gender,
      height: _height,
      weight: _weight,
      heightUnit: _heightUnit,
      weightUnit: _weightUnit,
      experienceLevel: _experience,
      activityLevel: _activity,
      injuries: _injuries.isNotEmpty ? _injuries : null,
      trainingDaysPerWeek: _trainingDays,
      preferredSessionDuration: _sessionDuration,
      gymAccess: _gymAccess,
      availableEquipment: _equipment,
      goals: _goals.isEmpty ? [FitnessGoal.generalFitness] : _goals,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(onboardingNotifierProvider.notifier).update(profile);
    await ref.read(onboardingNotifierProvider.notifier).save();

    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PersonalDetailsStep(
                    nameCtrl: _nameCtrl,
                    age: _age,
                    gender: _gender,
                    height: _height,
                    weight: _weight,
                    heightUnit: _heightUnit,
                    weightUnit: _weightUnit,
                    onChanged: ({age, gender, height, weight, heightUnit, weightUnit}) {
                      setState(() {
                        if (age != null) _age = age;
                        if (gender != null) _gender = gender;
                        if (height != null) _height = height;
                        if (weight != null) _weight = weight;
                        if (heightUnit != null) _heightUnit = heightUnit;
                        if (weightUnit != null) _weightUnit = weightUnit;
                      });
                    },
                  ),
                  FitnessProfileStep(
                    experience: _experience,
                    activity: _activity,
                    injuries: _injuries,
                    onChanged: ({experience, activity, injuries}) {
                      setState(() {
                        if (experience != null) _experience = experience;
                        if (activity != null) _activity = activity;
                        if (injuries != null) _injuries = injuries;
                      });
                    },
                  ),
                  TrainingSetupStep(
                    trainingDays: _trainingDays,
                    sessionDuration: _sessionDuration,
                    gymAccess: _gymAccess,
                    equipment: _equipment,
                    onChanged: ({trainingDays, sessionDuration, gymAccess, equipment}) {
                      setState(() {
                        if (trainingDays != null) _trainingDays = trainingDays;
                        if (sessionDuration != null) _sessionDuration = sessionDuration;
                        if (gymAccess != null) _gymAccess = gymAccess;
                        if (equipment != null) _equipment = equipment;
                      });
                    },
                  ),
                  GoalsStep(
                    goals: _goals,
                    onChanged: (goals) => setState(() => _goals = goals),
                  ),
                ],
              ),
            ),
            _buildNavButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back),
              padding: EdgeInsets.zero,
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              _titles[_currentPage],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Text(
            '${_currentPage + 1}/4',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: i <= _currentPage ? kYellow : kCard,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _next,
        child: Text(_currentPage == 3 ? 'GET STARTED' : 'CONTINUE'),
      ),
    );
  }
}
