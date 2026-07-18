import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/milestones.dart';
import '../models/milestone.dart';
import '../providers.dart';
import '../widgets/share_milestone.dart';

/// The "Benefits" tab: the full recovery timeline. Reached milestones are
/// unlocked, bright, and shareable; future ones show when they'll arrive.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(activeAttemptProvider).valueOrNull;
    final now = DateTime.now();
    final day = attempt?.daysIn(now) ?? 0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Your body on day $day',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'What changes as the alcohol-free days add up. General wellness '
            'info — not medical advice. If you drink heavily every day, '
            'please talk to a doctor before stopping abruptly.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          for (final m in kMilestones)
            _TimelineEntry(
              milestone: m,
              day: day,
              reached:
                  attempt != null && m.isReached(attempt.startDate, now),
              subtitle: attempt == null
                  ? _durationLabel(m.hours)
                  : m.isReached(attempt.startDate, now)
                      ? 'Unlocked ${DateFormat.MMMd().format(m.reachedAt(attempt.startDate))}'
                      : 'Arrives ${DateFormat.MMMd().format(m.reachedAt(attempt.startDate))}',
            ),
        ],
      ),
    );
  }

  static String _durationLabel(int hours) =>
      hours < 24 ? '$hours hours in' : 'Day ${hours ~/ 24}';
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.milestone,
    required this.day,
    required this.reached,
    required this.subtitle,
  });

  final Milestone milestone;
  final int day;
  final bool reached;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: reached ? 1.0 : 0.55,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: reached ? scheme.secondaryContainer : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reached ? milestone.emoji : '🔒',
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(milestone.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.primary)),
                    const SizedBox(height: 6),
                    Text(milestone.body),
                    if (milestone.sourceNote != null) ...[
                      const SizedBox(height: 6),
                      Text(milestone.sourceNote!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              if (reached)
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: 'Share this milestone',
                  onPressed: () => shareMilestone(
                    context: context,
                    milestone: milestone,
                    day: day,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
