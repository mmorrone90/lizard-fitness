import 'package:flutter/cupertino.dart';
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get to know you", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextMuted)),
          const SizedBox(height: 24),
          LFTextField(
            controller: nameCtrl,
            label: 'Your name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 28),

          // Age
          _SectionHeader(title: 'Age'),
          const SizedBox(height: 12),
          _StepperRow(
            value: '$age yrs',
            onDecrement: age > 13 ? () => onChanged(age: age - 1) : null,
            onIncrement: age < 100 ? () => onChanged(age: age + 1) : null,
          ),
          const SizedBox(height: 28),

          // Gender
          _SectionHeader(title: 'Gender'),
          const SizedBox(height: 12),
          Row(
            children: Gender.values.map((g) {
              final selected = gender == g;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onChanged(gender: g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? kYellow : kCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? kYellow : kCardLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      g.label,
                      style: TextStyle(
                        color: selected ? kBlack : kTextMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Height
          Row(
            children: [
              _SectionHeader(title: 'Height'),
              const Spacer(),
              _UnitToggle<HeightUnit>(
                options: HeightUnit.values,
                selected: heightUnit,
                label: (u) => u.name,
                onChanged: (u) => onChanged(heightUnit: u),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DrumRollPicker(
            items: _heightItems(heightUnit),
            selectedIndex: _heightIndex(height, heightUnit),
            onChanged: (i) => onChanged(height: _heightFromIndex(i, heightUnit)),
          ),
          const SizedBox(height: 32),

          // Weight
          Row(
            children: [
              _SectionHeader(title: 'Weight'),
              const Spacer(),
              _UnitToggle<WeightUnit>(
                options: WeightUnit.values,
                selected: weightUnit,
                label: (u) => u.name,
                onChanged: (u) => onChanged(weightUnit: u),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DrumRollPicker(
            items: _weightItems(weightUnit),
            selectedIndex: _weightIndex(weight, weightUnit),
            onChanged: (i) => onChanged(weight: _weightFromIndex(i, weightUnit)),
          ),
        ],
      ),
    );
  }

  // Height helpers
  List<String> _heightItems(HeightUnit unit) {
    if (unit == HeightUnit.cm) {
      return List.generate(151, (i) => '${100 + i} cm');
    } else {
      // 3'0" to 7'11" in 1-inch steps = 60 steps
      return List.generate(60, (i) {
        final totalInches = 36 + i; // 3'0" = 36"
        final feet = totalInches ~/ 12;
        final inches = totalInches % 12;
        return "$feet'${inches.toString().padLeft(2, '0')}\"";
      });
    }
  }

  int _heightIndex(double h, HeightUnit unit) {
    if (unit == HeightUnit.cm) {
      return (h.clamp(100, 250).round() - 100);
    } else {
      final totalInches = (h / 2.54).round().clamp(36, 95);
      return (totalInches - 36);
    }
  }

  double _heightFromIndex(int i, HeightUnit unit) {
    if (unit == HeightUnit.cm) return (100 + i).toDouble();
    return ((36 + i) * 2.54).roundToDouble();
  }

  // Weight helpers
  List<String> _weightItems(WeightUnit unit) {
    if (unit == WeightUnit.kg) {
      return List.generate(541, (i) => '${(30.0 + i * 0.5).toStringAsFixed(1)} kg');
    } else {
      return List.generate(1261, (i) => '${(66.0 + i * 0.5).toStringAsFixed(1)} lb');
    }
  }

  int _weightIndex(double w, WeightUnit unit) {
    if (unit == WeightUnit.kg) {
      return ((w.clamp(30, 300) - 30) / 0.5).round();
    } else {
      final lb = w * 2.20462;
      return ((lb.clamp(66, 693) - 66) / 0.5).round();
    }
  }

  double _weightFromIndex(int i, WeightUnit unit) {
    if (unit == WeightUnit.kg) return (30.0 + i * 0.5);
    return ((66.0 + i * 0.5) / 2.20462).roundToDouble();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
  );
}

class _StepperRow extends StatelessWidget {
  final String value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _StepperRow({required this.value, this.onDecrement, this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleBtn(icon: Icons.remove, onPressed: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          _CircleBtn(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const _CircleBtn({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: onPressed != null ? kYellow.withOpacity(0.12) : kCardLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: onPressed != null ? kYellow : kTextMuted),
      ),
    );
  }
}

class _UnitToggle<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final void Function(T) onChanged;

  const _UnitToggle({required this.options, required this.selected, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final sel = opt == selected;
          return GestureDetector(
            onTap: () => onChanged(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? kYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label(opt),
                style: TextStyle(
                  color: sel ? kBlack : kTextMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DrumRollPicker extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final void Function(int) onChanged;

  const _DrumRollPicker({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<_DrumRollPicker> createState() => _DrumRollPickerState();
}

class _DrumRollPickerState extends State<_DrumRollPicker> {
  late FixedExtentScrollController _ctrl;
  static const _itemH = 52.0;

  @override
  void initState() {
    super.initState();
    _ctrl = FixedExtentScrollController(initialItem: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(_DrumRollPicker old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex && _ctrl.hasClients) {
      final current = _ctrl.selectedItem;
      if (current != widget.selectedIndex) {
        _ctrl.jumpToItem(widget.selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _itemH * 5,
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Selection highlight
          Positioned(
            top: _itemH * 2,
            left: 0,
            right: 0,
            height: _itemH,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kYellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kYellow.withOpacity(0.3), width: 1.5),
              ),
            ),
          ),
          // Top fade
          Positioned(
            top: 0, left: 0, right: 0,
            height: _itemH * 2,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kCard, kCard.withOpacity(0)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),
          ),
          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: _itemH * 2,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [kCard, kCard.withOpacity(0)],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
              ),
            ),
          ),
          // Scroll wheel
          ListWheelScrollView.useDelegate(
            controller: _ctrl,
            itemExtent: _itemH,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.003,
            diameterRatio: 2.5,
            onSelectedItemChanged: widget.onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, i) {
                final selected = i == (_ctrl.hasClients ? _ctrl.selectedItem : widget.selectedIndex);
                return Center(
                  child: Text(
                    widget.items[i],
                    style: TextStyle(
                      color: selected ? kYellow : kTextMuted,
                      fontSize: selected ? 22 : 16,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                      letterSpacing: selected ? 0.5 : 0,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
