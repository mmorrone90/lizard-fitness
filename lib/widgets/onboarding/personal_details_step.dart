import 'package:flutter/material.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/common/lf_text_field.dart';

class PersonalDetailsStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final int age;
  final Gender gender;
  final double height;
  final double weight;
  final HeightUnit heightUnit;
  final WeightUnit weightUnit;
  final void Function({
    int? age, Gender? gender, double? height, double? weight,
    HeightUnit? heightUnit, WeightUnit? weightUnit,
  }) onChanged;

  const PersonalDetailsStep({
    super.key,
    required this.nameCtrl,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.heightUnit,
    required this.weightUnit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get to know you", style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          LFTextField(
            controller: nameCtrl,
            label: 'Your name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          _labelText('Age', context),
          const SizedBox(height: 8),
          _NumberPicker(
            value: age,
            min: 13, max: 100, unit: 'years',
            onChanged: (v) => onChanged(age: v),
          ),
          const SizedBox(height: 20),
          _labelText('Gender', context),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: Gender.values.map((g) => ChoiceChip(
              label: Text(g.label),
              selected: gender == g,
              onSelected: (_) => onChanged(gender: g),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelText('Height', context),
                    const SizedBox(height: 8),
                    _NumberPickerDouble(
                      value: height,
                      min: heightUnit == HeightUnit.cm ? 100 : 3,
                      max: heightUnit == HeightUnit.cm ? 250 : 8,
                      step: heightUnit == HeightUnit.cm ? 1 : 0.1,
                      unit: heightUnit.name,
                      onChanged: (v) => onChanged(height: v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelText('Weight', context),
                    const SizedBox(height: 8),
                    _NumberPickerDouble(
                      value: weight,
                      min: 30,
                      max: weightUnit == WeightUnit.kg ? 300 : 660,
                      step: 0.5,
                      unit: weightUnit.name,
                      onChanged: (v) => onChanged(weight: v),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _labelText('Units: ', context),
              const SizedBox(width: 8),
              SegmentedButton<HeightUnit>(
                segments: const [
                  ButtonSegment(value: HeightUnit.cm, label: Text('cm')),
                  ButtonSegment(value: HeightUnit.ft, label: Text('ft')),
                ],
                selected: {heightUnit},
                onSelectionChanged: (s) => onChanged(heightUnit: s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: kYellow,
                  selectedForegroundColor: kBlack,
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<WeightUnit>(
                segments: const [
                  ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                  ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                ],
                selected: {weightUnit},
                onSelectionChanged: (s) => onChanged(weightUnit: s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: kYellow,
                  selectedForegroundColor: kBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelText(String text, BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _NumberPicker extends StatelessWidget {
  final int value;
  final int min, max;
  final String unit;
  final void Function(int) onChanged;

  const _NumberPicker({
    required this.value, required this.min, required this.max,
    required this.unit, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('$value $unit', style: Theme.of(context).textTheme.titleLarge),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _NumberPickerDouble extends StatelessWidget {
  final double value;
  final double min, max, step;
  final String unit;
  final void Function(double) onChanged;

  const _NumberPickerDouble({
    required this.value, required this.min, required this.max,
    required this.step, required this.unit, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > min ? () => onChanged(double.parse((value - step).toStringAsFixed(1))) : null,
          ),
          Text(value.toStringAsFixed(step < 1 ? 1 : 0), style: Theme.of(context).textTheme.titleMedium),
          Text(' $unit', style: Theme.of(context).textTheme.bodySmall),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: value < max ? () => onChanged(double.parse((value + step).toStringAsFixed(1))) : null,
          ),
        ],
      ),
    );
  }
}
