import 'package:cloud_firestore/cloud_firestore.dart';

/// Per-user settings and onboarding answers. Money/calorie savings are
/// estimated from typical weekly spend and drinks, entered once during
/// onboarding and editable in settings.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.displayName,
    this.weeklySpendUsd = 0,
    this.drinksPerWeek = 0,
    this.onboarded = false,
  });

  final String uid;
  final String? displayName;

  /// Typical money spent on alcohol per week, in whole dollars.
  final int weeklySpendUsd;

  /// Typical standard drinks per week (a standard drink ≈ 150 kcal).
  final int drinksPerWeek;

  final bool onboarded;

  static const int kcalPerDrink = 150;

  double moneySavedThroughDay(int totalDays) =>
      weeklySpendUsd * totalDays / 7.0;

  int caloriesAvoidedThroughDay(int totalDays) =>
      (drinksPerWeek * totalDays / 7.0 * kcalPerDrink).round();

  int drinksSkippedThroughDay(int totalDays) =>
      (drinksPerWeek * totalDays / 7.0).round();

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String?,
      weeklySpendUsd: (data['weeklySpendUsd'] as num?)?.toInt() ?? 0,
      drinksPerWeek: (data['drinksPerWeek'] as num?)?.toInt() ?? 0,
      onboarded: data['onboarded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'weeklySpendUsd': weeklySpendUsd,
        'drinksPerWeek': drinksPerWeek,
        'onboarded': onboarded,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
