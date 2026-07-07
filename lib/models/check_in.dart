import 'package:cloud_firestore/cloud_firestore.dart';

enum Mood { rough, meh, okay, good, great }

/// A once-a-day reflection: how you feel, how strong cravings were, and an
/// optional note. Doc ID is the date (yyyy-MM-dd) so writes are idempotent
/// and there can only ever be one check-in per day.
class CheckIn {
  const CheckIn({
    required this.date,
    required this.mood,
    required this.craving,
    this.note,
  });

  /// Date key, e.g. '2026-07-07' (user's local date).
  final String date;

  final Mood mood;

  /// Craving intensity 0 (none) to 4 (intense).
  final int craving;

  final String? note;

  factory CheckIn.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CheckIn(
      date: doc.id,
      mood: Mood.values[(data['mood'] as num?)?.toInt() ?? 2],
      craving: (data['craving'] as num?)?.toInt() ?? 0,
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'mood': mood.index,
        'craving': craving,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
