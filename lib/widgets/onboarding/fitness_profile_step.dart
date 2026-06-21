import 'package:flutter/material.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/common/lf_text_field.dart';

class FitnessProfileStep extends StatefulWidget {
  final ExperienceLevel experience;
  final ActivityLevel activity;
  final String injuries;
  final void Function({ExperienceLevel? experience, ActivityLevel? activity, String? injuries}) onChanged;

  const FitnessProfileStep({
    super.key,
    required this.experience,
    required this.activity,
    required this.injuries,
    required this.onChanged,
  });

  @override
  State<FitnessProfileStep> createState() => _FitnessProfileStepState();
}

class _FitnessProfileStepState extends State<FitnessProfileStep> {
  late final TextEditingController _injuriesCtrl;

  @override
  void initState() {
    super.initState();
    _injuriesCtrl = TextEditingController(text: widget.injuries);
  }

  @override
  void dispose() {
    _injuriesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about your fitness background', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Experience level', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...ExperienceLevel.values.map((e) => _ExperienceCard(
            level: e,
            selected: widget.experience == e,
            onTap: () => widget.onChanged(experience: e),
          )),
          const SizedBox(height: 24),
          Text('Current activity level', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...ActivityLevel.values.map((a) => _OptionTile(
            title: a.label,
            selected: widget.activity == a,
            onTap: () => widget.onChanged(activity: a),
          )),
          const SizedBox(height: 24),
          Text('Injuries or limitations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Optional — helps us recommend safer exercises', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          LFTextField(
            controller: _injuriesCtrl,
            label: 'e.g. bad knees, lower back issues',
            maxLines: 3,
            onChanged: (v) => widget.onChanged(injuries: v),
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final ExperienceLevel level;
  final bool selected;
  final VoidCallback onTap;

  const _ExperienceCard({required this.level, required this.selected, required this.onTap});

  String get _description => switch (level) {
    ExperienceLevel.beginner => 'New to training or less than 1 year of consistent gym experience',
    ExperienceLevel.intermediate => '1-3 years of consistent training, familiar with compound lifts',
    ExperienceLevel.advanced => '3+ years of training, good knowledge of programming and technique',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? kYellow.withOpacity(0.12) : kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kYellow : kCardLight, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(level.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? kYellow : kTextPrimary,
                  )),
                  const SizedBox(height: 4),
                  Text(_description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: kYellow, size: 20),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.title, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kYellow.withOpacity(0.12) : kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? kYellow : kCardLight, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: selected ? kYellow : kTextPrimary,
            ))),
            if (selected) const Icon(Icons.check_circle, color: kYellow, size: 18),
          ],
        ),
      ),
    );
  }
}
