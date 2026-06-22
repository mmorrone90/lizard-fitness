import 'package:flutter/material.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

/// Horizontal week strip (Mon–Sun) marking days that have a logged workout,
/// with a left progress ring showing sessions completed this week.
class WeekStrip extends StatelessWidget {
  final List<WorkoutSession> sessions;
  final int weeklyGoal;

  const WeekStrip({super.key, required this.sessions, this.weeklyGoal = 4});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Monday as start of week.
    final monday = today.subtract(Duration(days: today.weekday - 1));

    // Set of trained day-dates (normalized).
    final trained = <DateTime>{};
    for (final s in sessions) {
      final c = s.completedAt;
      if (c == null) continue;
      trained.add(DateTime(c.year, c.month, c.day));
    }

    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    final thisWeekCount = days.where(trained.contains).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          _ProgressRing(value: thisWeekCount, goal: weeklyGoal),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((d) {
                final isTrained = trained.contains(d);
                final isToday = d == today;
                final isFuture = d.isAfter(today);
                return _DayCell(
                  letter: _letters[d.weekday - 1],
                  trained: isTrained,
                  today: isToday,
                  future: isFuture,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static const _letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
}

class _ProgressRing extends StatelessWidget {
  final int value;
  final int goal;
  const _ProgressRing({required this.value, required this.goal});

  @override
  Widget build(BuildContext context) {
    final pct = goal == 0 ? 0.0 : (value / goal).clamp(0.0, 1.0);
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: pct,
              strokeWidth: 5,
              backgroundColor: kCardLight,
              valueColor: const AlwaysStoppedAnimation(kYellow),
              strokeCap: StrokeCap.round,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value', style: const TextStyle(color: kYellow, fontWeight: FontWeight.w800, fontSize: 16)),
              const Icon(Icons.bolt, color: kYellow, size: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String letter;
  final bool trained;
  final bool today;
  final bool future;

  const _DayCell({required this.letter, required this.trained, required this.today, required this.future});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (trained) {
      bg = kYellow;
      fg = kBlack;
    } else if (today) {
      bg = Colors.transparent;
      fg = kYellow;
    } else {
      bg = kCardLight.withOpacity(0.5);
      fg = future ? kTextMuted : kTextSecondary;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: today && !trained ? Border.all(color: kYellow, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: trained
          ? const Icon(Icons.check, color: kBlack, size: 16)
          : Text(letter, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
