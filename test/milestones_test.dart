import 'package:dry30/data/milestones.dart';
import 'package:dry30/data/quotes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2026, 7, 1, 0, 0);

  group('milestone content', () {
    test('is ordered by hours and has unique ids', () {
      for (var i = 1; i < kMilestones.length; i++) {
        expect(kMilestones[i].hours, greaterThan(kMilestones[i - 1].hours));
      }
      final ids = kMilestones.map((m) => m.id).toSet();
      expect(ids.length, kMilestones.length);
    });

    test('covers the full 30 days', () {
      expect(kMilestones.first.hours, 1);
      expect(kMilestones.last.hours, 30 * 24);
    });
  });

  group('milestone progression', () {
    test('nothing reached before the first milestone', () {
      final now = start.add(const Duration(minutes: 30));
      expect(latestMilestone(start, now), isNull);
      expect(nextMilestone(start, now)!.id, 'h1');
      expect(reachedMilestones(start, now), isEmpty);
    });

    test('day 3 unlocks through d3 and points at d5 next', () {
      final now = start.add(const Duration(hours: 73));
      expect(latestMilestone(start, now)!.id, 'd3');
      expect(nextMilestone(start, now)!.id, 'd5');
      expect(reachedMilestones(start, now).first.id, 'd3');
    });

    test('after day 30 everything is reached and next is null', () {
      final now = start.add(const Duration(days: 31));
      expect(latestMilestone(start, now)!.id, 'd30');
      expect(nextMilestone(start, now), isNull);
      expect(reachedMilestones(start, now).length, kMilestones.length);
    });

    test('reachedAt matches hours offset', () {
      final d14 = kMilestones.firstWhere((m) => m.id == 'd14');
      expect(d14.reachedAt(start), start.add(const Duration(hours: 336)));
    });
  });

  group('quotes', () {
    test('has 30 daily quotes', () {
      expect(kDailyQuotes.length, 30);
    });

    test('wraps past day 30 and clamps below day 1', () {
      expect(quoteForDay(31), kDailyQuotes[0]);
      expect(quoteForDay(60), kDailyQuotes[29]);
      expect(quoteForDay(0), kDailyQuotes[0]);
      expect(quoteForDay(-5), kDailyQuotes[0]);
    });
  });
}
