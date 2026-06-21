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

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  OnboardingProfile? _profile;
  bool _loading = true;

  // Local editable copies
  late final TextEditingController _nameCtrl;
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

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final p = await ref.read(firestoreServiceProvider).getOnboardingProfile(uid);
    if (p != null && mounted) {
      setState(() {
        _profile = p;
        _nameCtrl.text = p.name;
        _age = p.age;
        _gender = p.gender;
        _height = p.height;
        _weight = p.weight;
        _heightUnit = p.heightUnit;
        _weightUnit = p.weightUnit;
        _experience = p.experienceLevel;
        _activity = p.activityLevel;
        _injuries = p.injuries ?? '';
        _trainingDays = p.trainingDaysPerWeek;
        _sessionDuration = p.preferredSessionDuration;
        _gymAccess = p.gymAccess;
        _equipment = List.from(p.availableEquipment);
        _goals = List.from(p.goals);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    final updated = (_profile ?? OnboardingProfile(
      userId: uid,
      name: '', age: 25, gender: Gender.preferNotToSay,
      height: 175, weight: 75, heightUnit: HeightUnit.cm, weightUnit: WeightUnit.kg,
      experienceLevel: ExperienceLevel.beginner, activityLevel: ActivityLevel.moderatelyActive,
      trainingDaysPerWeek: 3, preferredSessionDuration: 45,
      gymAccess: GymAccess.fullGym, availableEquipment: [], goals: [],
      createdAt: DateTime.now(), updatedAt: DateTime.now(),
    )).copyWith(
      name: _nameCtrl.text.trim(),
      age: _age, gender: _gender, height: _height, weight: _weight,
      heightUnit: _heightUnit, weightUnit: _weightUnit,
      experienceLevel: _experience, activityLevel: _activity,
      injuries: _injuries.isNotEmpty ? _injuries : null,
      trainingDaysPerWeek: _trainingDays, preferredSessionDuration: _sessionDuration,
      gymAccess: _gymAccess, availableEquipment: _equipment, goals: _goals,
      updatedAt: DateTime.now(),
    );

    ref.read(onboardingNotifierProvider.notifier).update(updated);
    await ref.read(onboardingNotifierProvider.notifier).save();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: kYellow)));
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: kBlack,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            TextButton(onPressed: _save, child: const Text('Save', style: TextStyle(color: kYellow))),
          ],
          bottom: const TabBar(
            indicatorColor: kYellow,
            labelColor: kYellow,
            unselectedLabelColor: kTextMuted,
            tabs: [
              Tab(text: 'Personal'),
              Tab(text: 'Fitness'),
              Tab(text: 'Training'),
              Tab(text: 'Goals'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PersonalDetailsStep(
              nameCtrl: _nameCtrl, age: _age, gender: _gender,
              height: _height, weight: _weight, heightUnit: _heightUnit, weightUnit: _weightUnit,
              onChanged: ({age, gender, height, weight, heightUnit, weightUnit}) => setState(() {
                if (age != null) _age = age;
                if (gender != null) _gender = gender;
                if (height != null) _height = height;
                if (weight != null) _weight = weight;
                if (heightUnit != null) _heightUnit = heightUnit;
                if (weightUnit != null) _weightUnit = weightUnit;
              }),
            ),
            FitnessProfileStep(
              experience: _experience, activity: _activity, injuries: _injuries,
              onChanged: ({experience, activity, injuries}) => setState(() {
                if (experience != null) _experience = experience;
                if (activity != null) _activity = activity;
                if (injuries != null) _injuries = injuries;
              }),
            ),
            TrainingSetupStep(
              trainingDays: _trainingDays, sessionDuration: _sessionDuration,
              gymAccess: _gymAccess, equipment: _equipment,
              onChanged: ({trainingDays, sessionDuration, gymAccess, equipment}) => setState(() {
                if (trainingDays != null) _trainingDays = trainingDays;
                if (sessionDuration != null) _sessionDuration = sessionDuration;
                if (gymAccess != null) _gymAccess = gymAccess;
                if (equipment != null) _equipment = equipment;
              }),
            ),
            GoalsStep(goals: _goals, onChanged: (g) => setState(() => _goals = g)),
          ],
        ),
      ),
    );
  }
}
