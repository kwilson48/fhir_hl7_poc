import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/milestones.dart';
import '../models/milestone.dart';
import '../models/sober_attempt.dart';
import '../models/user_profile.dart';

/// A notification we intend to schedule. Pure data so the planning logic is
/// unit-testable without the plugin.
class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.fireAt,
  });

  final int id;
  final String title;
  final String body;
  final DateTime fireAt;
}

/// IDs: 0 = daily reminder, 100+i = milestone i. Rescheduling always clears
/// everything first, so stable IDs just keep the plugin's store tidy.
const int kDailyReminderId = 0;
const int kMilestoneIdBase = 100;

/// Plans milestone-unlock notifications for an active attempt: one for each
/// milestone still in the future (capped so we never exceed iOS's pending
/// notification limit).
List<PlannedNotification> planMilestoneNotifications(
  SoberAttempt attempt,
  DateTime now, {
  int maxPending = 24,
}) {
  final planned = <PlannedNotification>[];
  for (var i = 0; i < kMilestones.length; i++) {
    final Milestone m = kMilestones[i];
    final fireAt = m.reachedAt(attempt.startDate);
    if (!fireAt.isAfter(now)) continue;
    planned.add(PlannedNotification(
      id: kMilestoneIdBase + i,
      title: '${m.emoji} Milestone unlocked: ${m.title}',
      body: m.body,
      fireAt: fireAt,
    ));
    if (planned.length >= maxPending) break;
  }
  return planned;
}

/// Next occurrence of [hour]:00 local time strictly after [now].
DateTime nextDailyReminder(DateTime now, int hour) {
  var candidate = DateTime(now.year, now.month, now.day, hour);
  if (!candidate.isAfter(now)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}

/// Thin wrapper around flutter_local_notifications. No-ops on web, where
/// scheduled local notifications aren't supported.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb || _ready) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name.identifier));
    } catch (_) {
      // Fall back to the plugin default (UTC); reminders still fire, just
      // possibly offset. Better than crashing on obscure timezone names.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _ready = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'dry30',
      'Dry30',
      channelDescription: 'Milestones and daily check-in reminders',
      importance: Importance.defaultImportance,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Clears everything and reschedules from the current attempt + profile.
  /// Called whenever either changes, so state converges instead of drifting.
  Future<void> sync(SoberAttempt? attempt, UserProfile profile) async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancelAll();

    final now = DateTime.now();

    if (profile.milestoneAlerts && attempt != null && attempt.isActive) {
      for (final n in planMilestoneNotifications(attempt, now)) {
        await _plugin.zonedSchedule(
          id: n.id,
          title: n.title,
          body: n.body,
          scheduledDate: tz.TZDateTime.from(n.fireAt, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    if (profile.dailyReminder) {
      final first = nextDailyReminder(now, profile.reminderHour);
      await _plugin.zonedSchedule(
        id: kDailyReminderId,
        title: 'How was today?',
        body: 'Take 20 seconds to check in and keep your streak honest.',
        scheduledDate: tz.TZDateTime.from(first, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      );
    }
  }
}
