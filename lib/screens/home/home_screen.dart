import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/providers/workout_provider.dart';
import 'package:lizard_fitness/providers/home_provider.dart';
import 'package:lizard_fitness/providers/onboarding_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/widgets/home/streak_card.dart';
import 'package:lizard_fitness/widgets/home/weekly_summary_card.dart';
import 'package:lizard_fitness/widgets/home/recent_workouts_list.dart';
import 'package:lizard_fitness/widgets/home/volume_chart.dart';
import 'package:lizard_fitness/widgets/home/personal_records_section.dart';
import 'package:lizard_fitness/widgets/home/today_workout_card.dart';
import 'package:lizard_fitness/widgets/home/week_strip.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    if (user == null) return const SizedBox();

    final sessions = ref.watch(workoutSessionsProvider(user.uid));
    final profile = ref.watch(onboardingProfileProvider(user.uid));
    final templates = ref.watch(workoutTemplatesProvider);

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, user.displayName ?? 'Athlete')),
            SliverToBoxAdapter(
              child: sessions.when(
                data: (list) {
                  final streak = computeStreak(list);
                  final summary = computeWeeklySummary(list);
                  return Column(
                    children: [
                      WeekStrip(sessions: list),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TodayWorkoutCard(
                          profile: profile.valueOrNull,
                          templates: templates.valueOrNull ?? [],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: StreakCard(streak: streak)),
                            const SizedBox(width: 12),
                            Expanded(child: WeeklySummaryCard(summary: summary)),
                          ],
                        ),
                      ),
                      if (list.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: VolumeChart(sessions: list.take(8).toList()),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PersonalRecordsSection(uid: user.uid),
                      const SizedBox(height: 24),
                      RecentWorkoutsList(sessions: list.take(5).toList()),
                      const SizedBox(height: 24),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(child: CircularProgressIndicator(color: kYellow)),
                ),
                error: (e, _) => const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good morning' : now.hour < 17 ? 'Good afternoon' : 'Good evening';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting,', style: Theme.of(context).textTheme.bodyMedium),
              Text(name.split(' ').first, style: Theme.of(context).textTheme.displaySmall),
            ],
          ),
          Text(
            DateFormat('EEE, MMM d').format(now),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
