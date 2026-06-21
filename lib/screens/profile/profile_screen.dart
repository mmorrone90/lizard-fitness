import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';
import 'package:lizard_fitness/providers/onboarding_provider.dart';
import 'package:lizard_fitness/providers/workout_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    if (user == null) return const SizedBox();

    final profile = ref.watch(onboardingProfileProvider(user.uid));
    final sessions = ref.watch(workoutSessionsProvider(user.uid));

    return Scaffold(
      backgroundColor: kBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                displayName: user.displayName ?? 'Athlete',
                email: user.email ?? '',
                avatarUrl: null,
              ),
            ),
            SliverToBoxAdapter(
              child: sessions.when(
                data: (list) {
                  final totalSessions = list.length;
                  final totalVolume = list.fold(0.0, (s, sess) => s + sess.totalVolume);
                  return _StatsRow(totalSessions: totalSessions, totalVolume: totalVolume);
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ),
            SliverToBoxAdapter(
              child: profile.when(
                data: (p) => p != null ? _ProfileDetails(profile: p) : const SizedBox(),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ),
            SliverToBoxAdapter(child: _SettingsSection()),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? avatarUrl;

  const _ProfileHeader({required this.displayName, required this.email, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: kYellow.withOpacity(0.2),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
                    style: const TextStyle(color: kYellow, fontSize: 32, fontWeight: FontWeight.w800),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 2),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: kYellow),
            onPressed: () => GoRouter.of(context).push('/profile/edit'),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalSessions;
  final double totalVolume;

  const _StatsRow({required this.totalSessions, required this.totalVolume});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.fitness_center,
              value: '$totalSessions',
              label: 'Workouts',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.bar_chart,
              value: NumberFormat('#,##0').format(totalVolume),
              label: 'kg Lifted',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(icon, color: kYellow, size: 24),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: kYellow)),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final OnboardingProfile profile;

  const _ProfileDetails({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Training Profile', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _DetailRow(label: 'Experience', value: profile.experienceLevel.label),
                _DetailRow(label: 'Training days', value: '${profile.trainingDaysPerWeek} days/week'),
                _DetailRow(label: 'Session duration', value: '${profile.preferredSessionDuration} min'),
                _DetailRow(label: 'Gym access', value: profile.gymAccess.label),
                _DetailRow(label: 'Plan type', value: profile.recommendedPlanType ?? 'Custom'),
                _DetailRow(label: 'Weight', value: profile.weightDisplay, last: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Goals', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.goals.map((g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kYellow.withOpacity(0.3)),
              ),
              child: Text('${g.emoji} ${g.label}', style: const TextStyle(color: kYellow, fontWeight: FontWeight.w600)),
            )).toList(),
          ),
          if (profile.injuries != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kWarning.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_outlined, color: kWarning, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(profile.injuries!, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _DetailRow({required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        if (!last) const Divider(height: 1),
      ],
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile & Onboarding',
                  onTap: () => context.push('/profile/edit'),
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notification Settings',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Settings',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.logout,
                  title: 'Log Out',
                  color: kError,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: kCard,
                        title: const Text('Log out?'),
                        content: const Text('You will need to log in again.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Log out', style: TextStyle(color: kError)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = kTextPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: color == kTextPrimary ? kTextMuted : color, size: 18),
      onTap: onTap,
    );
  }
}
