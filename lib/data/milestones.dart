import '../models/milestone.dart';

/// The recovery timeline for a 30-day alcohol-free challenge.
///
/// Milestones are ordered by [Milestone.hours]. The copy is written to be
/// encouraging and honest (including that days 2-5 can feel rough), and is
/// based on published research on short-term abstinence — most notably the
/// Royal Free Hospital "Dry January" studies (Mehta et al., BMJ Open 2018)
/// and general clinical literature on sleep, hydration, and liver recovery.
/// It is general wellness information, not medical advice.
const List<Milestone> kMilestones = [
  Milestone(
    id: 'h1',
    hours: 1,
    emoji: '🌱',
    title: 'It begins',
    body:
        'Your liver is already clearing the last of the alcohol from your '
        'blood. From this moment on, every system in your body gets to focus '
        'on repair instead of processing a toxin.',
  ),
  Milestone(
    id: 'h12',
    hours: 12,
    emoji: '💧',
    title: 'Blood alcohol: zero',
    body:
        'For most people, blood alcohol is back to zero by now. Your blood '
        'sugar is stabilizing and your kidneys are rehydrating your body — '
        'alcohol is a diuretic, so this is the first thing to bounce back.',
  ),
  Milestone(
    id: 'd1',
    hours: 24,
    emoji: '☀️',
    title: '24 hours — day one done',
    body:
        'The hardest day is behind you. Your body is fully rehydrating, your '
        'stomach lining has started calming down, and your liver has begun '
        'shifting from "clean-up crew" to "repair crew."',
  ),
  Milestone(
    id: 'd2',
    hours: 48,
    emoji: '🧠',
    title: 'Your brain rebalances',
    body:
        'Heads up: nights 2-5 can bring restless sleep or vivid dreams as '
        'your brain chemistry rebalances without alcohol. It feels backwards, '
        'but it is a sign of recovery — and it is temporary.',
    sourceNote:
        'Alcohol suppresses REM sleep; a short "REM rebound" is common when '
        'you stop.',
  ),
  Milestone(
    id: 'd3',
    hours: 72,
    emoji: '⚡',
    title: 'Energy returns',
    body:
        'For most people the physical adjustment peaks and passes by day 3. '
        'Blood sugar swings level out and many people feel the first real '
        'lift in energy right about now.',
  ),
  Milestone(
    id: 'd5',
    hours: 120,
    emoji: '😴',
    title: 'Real sleep is back',
    body:
        'Deep, restorative sleep is returning. Alcohol fragments sleep even '
        'in small amounts, so nights without it mean more REM and deep-sleep '
        'cycles — the kind that actually repair your body and mind.',
  ),
  Milestone(
    id: 'd7',
    hours: 168,
    emoji: '✨',
    title: 'One full week',
    body:
        'Your skin is noticeably more hydrated — alcohol dehydrates skin and '
        'widens blood vessels, so puffiness and redness fade this week. '
        'You have also likely skipped a few thousand empty calories already.',
  ),
  Milestone(
    id: 'd10',
    hours: 240,
    emoji: '🎯',
    title: 'Double digits',
    body:
        'Ten days. Mental fog keeps lifting: concentration and short-term '
        'memory improve as your sleep debt gets repaid. Cravings, if you get '
        'them, are usually shorter and easier to ride out by now.',
  ),
  Milestone(
    id: 'd14',
    hours: 336,
    emoji: '🫀',
    title: 'Two weeks — your liver thanks you',
    body:
        'Your liver has had two weeks of nights off, and fat stored in the '
        'liver is measurably decreasing. Stomach acid production normalizes, '
        'so heartburn and reflux often ease around now.',
    sourceNote:
        'A month of abstinence reduced liver fat by ~15% on average in the '
        'Royal Free Hospital study (Mehta et al., BMJ Open 2018).',
  ),
  Milestone(
    id: 'd21',
    hours: 504,
    emoji: '💪',
    title: 'Three weeks — heart & metabolism',
    body:
        'Blood pressure trends down and your body handles sugar better — '
        'studies of one-month breaks found meaningful drops in blood '
        'pressure and insulin resistance by this point. New habits are '
        'starting to feel like just… habits.',
    sourceNote:
        'The same BMJ Open study found ~25% improvement in insulin '
        'resistance and lower blood pressure after one month off.',
  ),
  Milestone(
    id: 'd25',
    hours: 600,
    emoji: '🛡️',
    title: 'Immune system online',
    body:
        'Alcohol suppresses immune function for days after drinking. After '
        'weeks without it, your immune system responds faster and you are '
        'better defended against everyday bugs.',
  ),
  Milestone(
    id: 'd30',
    hours: 720,
    emoji: '🏆',
    title: '30 days — you did it',
    body:
        'A full month. Liver fat down, blood pressure down, sleep deeper, '
        'skin clearer, mind sharper — and you have proven you can do hard '
        'things. Many people report this is where drinking loses its grip: '
        'most who complete a dry month still drink less six months later.',
    sourceNote:
        'Follow-up studies of Dry January participants show reduced drinking '
        'months after the challenge ends.',
  ),
];

/// Milestones already reached, most recent first.
List<Milestone> reachedMilestones(DateTime startDate, DateTime now) =>
    kMilestones.reversed
        .where((m) => m.isReached(startDate, now))
        .toList(growable: false);

/// The next milestone ahead, or null if all are reached.
Milestone? nextMilestone(DateTime startDate, DateTime now) {
  for (final m in kMilestones) {
    if (!m.isReached(startDate, now)) return m;
  }
  return null;
}

/// The most recently reached milestone, or null if none yet.
Milestone? latestMilestone(DateTime startDate, DateTime now) {
  Milestone? latest;
  for (final m in kMilestones) {
    if (m.isReached(startDate, now)) latest = m;
  }
  return latest;
}
