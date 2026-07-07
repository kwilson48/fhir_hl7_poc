import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/milestones.dart';
import '../data/quotes.dart';
import '../models/milestone.dart';
import '../providers.dart';
import '../widgets/progress_ring.dart';

/// The "Today" tab: day counter, quote of the day, latest & next milestone,
/// and savings stats.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(activeAttemptProvider).valueOrNull;
    final profile = ref.watch(profileProvider).valueOrNull;
    final lifetimeDays = ref.watch(lifetimeDaysProvider);
    final now = DateTime.now();

    if (attempt == null) {
      return const _NoAttemptView();
    }

    final day = attempt.daysIn(now);
    final latest = latestMilestone(attempt.startDate, now);
    final next = nextMilestone(attempt.startDate, now);
    final goalReached = attempt.goalReached(now);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: ProgressRing(
              progress: attempt.progress(now),
              day: day,
              goalDays: attempt.goalDays,
            ),
          ),
          const SizedBox(height: 16),
          if (goalReached)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '🏆 You completed the 30-day challenge! The counter keeps '
                  'going as long as you do.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          _QuoteCard(day: day),
          const SizedBox(height: 8),
          if (latest != null)
            _MilestoneTile(
              milestone: latest,
              header: 'Happening in your body now',
              highlighted: true,
            ),
          if (next != null)
            _MilestoneTile(
              milestone: next,
              header: 'Coming up: ${_countdown(next, attempt.startDate, now)}',
              highlighted: false,
            ),
          const SizedBox(height: 8),
          if (profile != null)
            _StatsRow(
              moneySaved: profile.moneySavedThroughDay(lifetimeDays),
              calories: profile.caloriesAvoidedThroughDay(lifetimeDays),
              drinks: profile.drinksSkippedThroughDay(lifetimeDays),
            ),
        ],
      ),
    );
  }

  static String _countdown(Milestone m, DateTime start, DateTime now) {
    final remaining = m.reachedAt(start).difference(now);
    if (remaining.inHours < 1) return 'less than an hour away';
    if (remaining.inHours < 48) {
      return 'in ${remaining.inHours} hour${remaining.inHours == 1 ? '' : 's'}';
    }
    return 'in ${remaining.inDays} days';
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TODAY\'S NUDGE',
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              quoteForDay(day),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({
    required this.milestone,
    required this.header,
    required this.highlighted,
  });

  final Milestone milestone;
  final String header;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: highlighted ? scheme.secondaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(header.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(milestone.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(milestone.body),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.moneySaved,
    required this.calories,
    required this.drinks,
  });

  final double moneySaved;
  final int calories;
  final int drinks;

  @override
  Widget build(BuildContext context) {
    if (moneySaved == 0 && calories == 0) return const SizedBox.shrink();
    return Row(
      children: [
        if (moneySaved > 0)
          Expanded(
            child: _StatCard(
              label: 'saved',
              value: '\$${moneySaved.toStringAsFixed(0)}',
              icon: Icons.savings_outlined,
            ),
          ),
        if (calories > 0) ...[
          if (moneySaved > 0) const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'calories skipped',
              value: _compact(calories),
              icon: Icons.local_fire_department_outlined,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'drinks skipped',
              value: '$drinks',
              icon: Icons.no_drinks_outlined,
            ),
          ),
        ],
      ],
    );
  }

  static String _compact(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NoAttemptView extends ConsumerWidget {
  const _NoAttemptView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('No active challenge.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final now = DateTime.now();
                ref
                    .read(firestoreServiceProvider)
                    ?.startAttempt(DateTime(now.year, now.month, now.day));
              },
              child: const Text('Start a new 30 days'),
            ),
          ],
        ),
      ),
    );
  }
}
