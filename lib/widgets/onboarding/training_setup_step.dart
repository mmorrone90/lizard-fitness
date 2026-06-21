import 'package:flutter/material.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class TrainingSetupStep extends StatelessWidget {
  final int trainingDays;
  final int sessionDuration;
  final GymAccess gymAccess;
  final List<String> equipment;
  final void Function({
    int? trainingDays, int? sessionDuration,
    GymAccess? gymAccess, List<String>? equipment,
  }) onChanged;

  const TrainingSetupStep({
    super.key,
    required this.trainingDays,
    required this.sessionDuration,
    required this.gymAccess,
    required this.equipment,
    required this.onChanged,
  });

  static const _equipmentOptions = [
    'Barbells', 'Dumbbells', 'Cables', 'Machines', 'Pull-up bar',
    'Bench', 'Squat rack', 'Kettlebells', 'Resistance bands', 'Foam roller',
  ];

  static const _durations = [20, 30, 45, 60, 75, 90];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set up your training schedule', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Days per week', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) {
              final day = i + 1;
              final selected = trainingDays == day;
              return GestureDetector(
                onTap: () => onChanged(trainingDays: day),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? kYellow : kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? kYellow : kCardLight),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: selected ? kBlack : kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Text('Session duration', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durations.map((d) {
              final selected = sessionDuration == d;
              return GestureDetector(
                onTap: () => onChanged(sessionDuration: d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? kYellow : kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? kYellow : kCardLight),
                  ),
                  child: Text(
                    '${d}min',
                    style: TextStyle(
                      color: selected ? kBlack : kTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Gym access', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...GymAccess.values.map((g) => GestureDetector(
            onTap: () => onChanged(gymAccess: g),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: gymAccess == g ? kYellow.withOpacity(0.12) : kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gymAccess == g ? kYellow : kCardLight, width: gymAccess == g ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(g.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: gymAccess == g ? kYellow : kTextPrimary,
                  ))),
                  if (gymAccess == g) const Icon(Icons.check_circle, color: kYellow, size: 18),
                ],
              ),
            ),
          )),
          const SizedBox(height: 24),
          Text('Available equipment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Select all that apply', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _equipmentOptions.map((e) {
              final selected = equipment.contains(e);
              return FilterChip(
                label: Text(e),
                selected: selected,
                onSelected: (_) {
                  final updated = List<String>.from(equipment);
                  if (selected) updated.remove(e); else updated.add(e);
                  onChanged(equipment: updated);
                },
                selectedColor: kYellow,
                labelStyle: TextStyle(color: selected ? kBlack : kTextPrimary),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
