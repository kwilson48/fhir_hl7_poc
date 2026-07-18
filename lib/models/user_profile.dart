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
    this.milestoneAlerts = true,
    this.dailyReminder = true,
    this.reminderHour = 20,
    this.supportContactName,
    this.supportContactPhone,
  });

  final String uid;
  final String? displayName;

  /// Typical money spent on alcohol per week, in whole dollars.
  final int weeklySpendUsd;

  /// Typical standard drinks per week (a standard drink ≈ 150 kcal).
  final int drinksPerWeek;

  final bool onboarded;

  /// Notify when a recovery milestone unlocks.
  final bool milestoneAlerts;

  /// Daily evening check-in reminder.
  final bool dailyReminder;

  /// Local hour (0-23) for the daily reminder.
  final int reminderHour;

  /// Someone to reach out to from the SOS screen.
  final String? supportContactName;
  final String? supportContactPhone;

  static const int kcalPerDrink = 150;

  double moneySavedThroughDay(int totalDays) =>
      weeklySpendUsd * totalDays / 7.0;

  int caloriesAvoidedThroughDay(int totalDays) =>
      (drinksPerWeek * totalDays / 7.0 * kcalPerDrink).round();

  int drinksSkippedThroughDay(int totalDays) =>
      (drinksPerWeek * totalDays / 7.0).round();

  UserProfile copyWith({
    int? weeklySpendUsd,
    int? drinksPerWeek,
    bool? onboarded,
    bool? milestoneAlerts,
    bool? dailyReminder,
    int? reminderHour,
    String? supportContactName,
    String? supportContactPhone,
  }) =>
      UserProfile(
        uid: uid,
        displayName: displayName,
        weeklySpendUsd: weeklySpendUsd ?? this.weeklySpendUsd,
        drinksPerWeek: drinksPerWeek ?? this.drinksPerWeek,
        onboarded: onboarded ?? this.onboarded,
        milestoneAlerts: milestoneAlerts ?? this.milestoneAlerts,
        dailyReminder: dailyReminder ?? this.dailyReminder,
        reminderHour: reminderHour ?? this.reminderHour,
        supportContactName: supportContactName ?? this.supportContactName,
        supportContactPhone: supportContactPhone ?? this.supportContactPhone,
      );

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String?,
      weeklySpendUsd: (data['weeklySpendUsd'] as num?)?.toInt() ?? 0,
      drinksPerWeek: (data['drinksPerWeek'] as num?)?.toInt() ?? 0,
      onboarded: data['onboarded'] as bool? ?? false,
      milestoneAlerts: data['milestoneAlerts'] as bool? ?? true,
      dailyReminder: data['dailyReminder'] as bool? ?? true,
      reminderHour: (data['reminderHour'] as num?)?.toInt() ?? 20,
      supportContactName: data['supportContactName'] as String?,
      supportContactPhone: data['supportContactPhone'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'weeklySpendUsd': weeklySpendUsd,
        'drinksPerWeek': drinksPerWeek,
        'onboarded': onboarded,
        'milestoneAlerts': milestoneAlerts,
        'dailyReminder': dailyReminder,
        'reminderHour': reminderHour,
        'supportContactName': supportContactName,
        'supportContactPhone': supportContactPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
