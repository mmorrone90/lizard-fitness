import 'package:flutter/material.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class GoalsStep extends StatelessWidget {
  final List<FitnessGoal> goals;
  final void Function(List<FitnessGoal>) onChanged;

  const GoalsStep({super.key, required this.goals, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What do you want to achieve?", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text("Select all that apply", style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          ...FitnessGoal.values.map((goal) {
            final selected = goals.contains(goal);
            return GestureDetector(
              onTap: () {
                final updated = List<FitnessGoal>.from(goals);
                if (selected) updated.remove(goal); else updated.add(goal);
                onChanged(updated);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? kYellow.withOpacity(0.12) : kCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? kYellow : kCardLight, width: selected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        goal.label,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: selected ? kYellow : kTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? kYellow : Colors.transparent,
                        border: Border.all(color: selected ? kYellow : kTextMuted, width: 2),
                      ),
                      child: selected ? const Icon(Icons.check, size: 14, color: kBlack) : null,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
