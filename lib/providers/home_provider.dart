import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';

final personalRecordsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).getPersonalRecords(uid);
});

final gymChallengesProvider = FutureProvider((ref) {
  return ref.watch(firestoreServiceProvider).getGymChallenges();
});

// Compute streak from sessions
int computeStreak(List<WorkoutSession> sessions) {
  if (sessions.isEmpty) return 0;

  final completed = sessions
      .where((s) => s.completedAt != null)
      .toList()
    ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  if (completed.isEmpty) return 0;

  int streak = 0;
  DateTime? lastDay;

  for (final session in completed) {
    final day = DateTime(
      session.completedAt!.year,
      session.completedAt!.month,
      session.completedAt!.day,
    );

    if (lastDay == null) {
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final diff = todayNorm.difference(day).inDays;
      if (diff > 1) break;
      streak = 1;
      lastDay = day;
    } else {
      final diff = lastDay.difference(day).inDays;
      if (diff == 1) {
        streak++;
        lastDay = day;
      } else if (diff == 0) {
        continue;
      } else {
        break;
      }
    }
  }

  return streak;
}

// Weekly summary
Map<String, dynamic> computeWeeklySummary(List<WorkoutSession> sessions) {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekStartNorm = DateTime(weekStart.year, weekStart.month, weekStart.day);

  final thisWeek = sessions.where((s) {
    if (s.completedAt == null) return false;
    return s.completedAt!.isAfter(weekStartNorm);
  }).toList();

  final totalVolume = thisWeek.fold(0.0, (sum, s) => sum + s.totalVolume);
  final totalDuration = thisWeek.fold(0, (sum, s) => sum + (s.duration ?? 0));

  return {
    'sessionsCount': thisWeek.length,
    'totalVolume': totalVolume,
    'totalDuration': totalDuration,
    'sessions': thisWeek,
  };
}
