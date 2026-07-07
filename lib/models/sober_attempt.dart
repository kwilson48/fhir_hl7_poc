import 'package:cloud_firestore/cloud_firestore.dart';

/// One run at the challenge. If someone slips, the attempt is closed and a
/// new one starts — history is kept, the streak resets, and nothing is
/// deleted. Total alcohol-free days across attempts never go down.
class SoberAttempt {
  const SoberAttempt({
    required this.id,
    required this.startDate,
    this.goalDays = 30,
    this.endedAt,
    this.endReason,
  });

  final String id;
  final DateTime startDate;
  final int goalDays;

  /// Set when the attempt ends (completed or reset). Null while active.
  final DateTime? endedAt;

  /// 'completed' or 'reset'.
  final String? endReason;

  bool get isActive => endedAt == null;

  /// Current day of the challenge, 1-based. Day 1 is the start date.
  int daysIn(DateTime now) {
    final effectiveEnd = endedAt ?? now;
    final days = effectiveEnd.difference(startDate).inDays + 1;
    return days < 1 ? 1 : days;
  }

  /// Fraction of the goal completed, clamped to 0..1.
  double progress(DateTime now) =>
      (now.difference(startDate).inHours / (goalDays * 24)).clamp(0.0, 1.0);

  bool goalReached(DateTime now) =>
      now.difference(startDate).inDays >= goalDays;

  factory SoberAttempt.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SoberAttempt(
      id: doc.id,
      startDate: (data['startDate'] as Timestamp).toDate(),
      goalDays: (data['goalDays'] as num?)?.toInt() ?? 30,
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      endReason: data['endReason'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'startDate': Timestamp.fromDate(startDate),
        'goalDays': goalDays,
        'endedAt': endedAt == null ? null : Timestamp.fromDate(endedAt!),
        'endReason': endReason,
      };
}
