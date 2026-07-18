import 'package:dry30/models/sober_attempt.dart';
import 'package:dry30/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 7, 1);

  group('SoberAttempt day math', () {
    const goal = 30;
    SoberAttempt attempt() =>
        SoberAttempt(id: 'a1', startDate: start, goalDays: goal);

    test('start date is day 1', () {
      expect(attempt().daysIn(start.add(const Duration(hours: 5))), 1);
    });

    test('next calendar day is day 2', () {
      expect(attempt().daysIn(start.add(const Duration(hours: 25))), 2);
    });

    test('goal reached exactly at 30 days', () {
      final a = attempt();
      expect(a.goalReached(start.add(const Duration(days: 29, hours: 23))),
          isFalse);
      expect(a.goalReached(start.add(const Duration(days: 30))), isTrue);
    });

    test('progress clamps to 0..1', () {
      final a = attempt();
      expect(a.progress(start), 0.0);
      expect(a.progress(start.add(const Duration(days: 15))), closeTo(0.5, 0.01));
      expect(a.progress(start.add(const Duration(days: 45))), 1.0);
    });

    test('ended attempt freezes its day count', () {
      final a = SoberAttempt(
        id: 'a2',
        startDate: start,
        endedAt: start.add(const Duration(days: 9)),
        endReason: 'reset',
      );
      // Even checked a year later, it contributed 10 days.
      expect(a.daysIn(start.add(const Duration(days: 365))), 10);
      expect(a.isActive, isFalse);
    });
  });

  group('UserProfile savings math', () {
    const profile = UserProfile(
      uid: 'u1',
      weeklySpendUsd: 70,
      drinksPerWeek: 14,
    );

    test('money saved is pro-rated per day', () {
      expect(profile.moneySavedThroughDay(7), 70.0);
      expect(profile.moneySavedThroughDay(30), closeTo(300, 0.01));
    });

    test('calories use 150 kcal per standard drink', () {
      expect(profile.caloriesAvoidedThroughDay(7), 14 * 150);
    });

    test('drinks skipped rounds sensibly', () {
      expect(profile.drinksSkippedThroughDay(7), 14);
      expect(profile.drinksSkippedThroughDay(1), 2);
    });

    test('zeroed profile reports zero savings', () {
      const empty = UserProfile(uid: 'u2');
      expect(empty.moneySavedThroughDay(30), 0);
      expect(empty.caloriesAvoidedThroughDay(30), 0);
    });
  });
}
