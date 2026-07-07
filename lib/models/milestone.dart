/// A point on the recovery timeline where the body/mind measurably benefits
/// from not drinking. Content ships with the app so the timeline works
/// offline; user progress against it is computed from their attempt start
/// date.
class Milestone {
  const Milestone({
    required this.id,
    required this.hours,
    required this.title,
    required this.body,
    required this.emoji,
    this.sourceNote,
  });

  final String id;

  /// Hours after the attempt's start when this milestone is reached.
  final int hours;

  final String title;
  final String body;
  final String emoji;

  /// Short plain-language pointer to the research this is based on, shown as
  /// a footnote. Not medical advice.
  final String? sourceNote;

  Duration get duration => Duration(hours: hours);

  bool isReached(DateTime startDate, DateTime now) =>
      now.difference(startDate) >= duration;

  DateTime reachedAt(DateTime startDate) => startDate.add(duration);
}
