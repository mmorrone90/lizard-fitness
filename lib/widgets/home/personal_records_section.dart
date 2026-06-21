import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/providers/home_provider.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class PersonalRecordsSection extends ConsumerWidget {
  final String uid;
  const PersonalRecordsSection({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prs = ref.watch(personalRecordsProvider(uid));

    return prs.when(
      data: (records) {
        if (records.isEmpty) return const SizedBox();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('Personal Records', style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              ...records.take(3).map((pr) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pr['exerciseName'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                          Text(pr['recordType'] ?? 'max weight', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      '${pr['value']} ${pr['unit']}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kYellow),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
