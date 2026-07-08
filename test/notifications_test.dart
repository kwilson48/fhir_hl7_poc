import 'package:dry30/data/milestones.dart';
import 'package:dry30/models/sober_attempt.dart';
import 'package:dry30/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 7, 1);

  SoberAttempt attempt() => SoberAttempt(id: 'a1', startDate: start);

  group('planMilestoneNotifications', () {
    test('on day 0 schedules every milestone, in order', () {
      final planned = planMilestoneNotifications(attempt(), start);
      expect(planned.length, kMilestones.length);
      expect(planned.first.fireAt, start.add(const Duration(hours: 1)));
      expect(planned.last.fireAt, start.add(const Duration(days: 30)));
      for (var i = 1; i < planned.length; i++) {
        expect(planned[i].fireAt.isAfter(planned[i - 1].fireAt), isTrue);
      }
    });

    test('skips milestones already reached', () {
      final now = start.add(const Duration(days: 14, hours: 1));
      final planned = planMilestoneNotifications(attempt(), now);
      expect(planned.every((n) => n.fireAt.isAfter(now)), isTrue);
      // d14 (336h) already passed; d21 (504h) is the next one.
      expect(planned.first.id, kMilestoneIdBase + kMilestones.indexWhere((m) => m.id == 'd21'));
    });

    test('returns nothing after day 30', () {
      final now = start.add(const Duration(days: 31));
      expect(planMilestoneNotifications(attempt(), now), isEmpty);
    });

    test('respects the pending cap', () {
      final planned =
          planMilestoneNotifications(attempt(), start, maxPending: 3);
      expect(planned.length, 3);
    });

    test('ids never collide with the daily reminder id', () {
      final planned = planMilestoneNotifications(attempt(), start);
      expect(planned.any((n) => n.id == kDailyReminderId), isFalse);
    });
  });

  group('nextDailyReminder', () {
    test('later today when the hour is still ahead', () {
      final now = DateTime(2026, 7, 8, 9, 30);
      expect(nextDailyReminder(now, 20), DateTime(2026, 7, 8, 20));
    });

    test('tomorrow when the hour already passed', () {
      final now = DateTime(2026, 7, 8, 21, 15);
      expect(nextDailyReminder(now, 20), DateTime(2026, 7, 9, 20));
    });

    test('tomorrow when exactly at the reminder time', () {
      final now = DateTime(2026, 7, 8, 20, 0);
      expect(nextDailyReminder(now, 20), DateTime(2026, 7, 9, 20));
    });
  });
}
