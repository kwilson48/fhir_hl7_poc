// Demo entrypoint: runs the full UI with in-memory fake data and NO Firebase
// project. Useful for UI development, screenshots, and design review:
//
//   flutter run -t lib/main_demo.dart -d chrome
//
// The demo user is on day 12 of 30 with a few check-ins and one past attempt.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'models/check_in.dart';
import 'models/sober_attempt.dart';
import 'models/user_profile.dart';
import 'providers.dart';
import 'screens/home_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sos_screen.dart';
import 'services/auth_service.dart';

/// Compiles without implementing FirebaseAuth; any actual call throws via
/// noSuchMethod. Fine for a demo where auth actions are never exercised.
class _FakeFirebaseAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();
  DateTime daysAgo(int d) =>
      DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
  String key(int d) => todayKey(daysAgo(d));

  final active = SoberAttempt(id: 'demo-active', startDate: daysAgo(11));
  final past = SoberAttempt(
    id: 'demo-past',
    startDate: daysAgo(30),
    endedAt: daysAgo(22),
    endReason: 'reset',
  );

  const profile = UserProfile(
    uid: 'demo',
    displayName: 'Demo',
    weeklySpendUsd: 60,
    drinksPerWeek: 12,
    onboarded: true,
    supportContactName: 'Kevin',
    supportContactPhone: '+15551234567',
  );

  final checkIns = [
    CheckIn(date: key(1), mood: Mood.good, craving: 1, note: 'Slept great.'),
    CheckIn(date: key(2), mood: Mood.okay, craving: 2),
    CheckIn(
        date: key(3),
        mood: Mood.great,
        craving: 0,
        note: 'Friday night was easier than expected.'),
  ];

  runApp(ProviderScope(
    overrides: [
      authServiceProvider
          .overrideWithValue(AuthService(_FakeFirebaseAuth())),
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      profileProvider.overrideWith((ref) => Stream.value(profile)),
      activeAttemptProvider.overrideWith((ref) => Stream.value(active)),
      allAttemptsProvider
          .overrideWith((ref) => Stream.value([active, past])),
      todaysCheckInProvider.overrideWith((ref) => Stream.value(null)),
      recentCheckInsProvider.overrideWith((ref) => Stream.value(checkIns)),
    ],
    child: const DemoApp(),
  ));
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dry30 (demo)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Dry30App.seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Dry30App.seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routes: {
        '/': (_) => const HomeShell(),
        '/signin': (_) => const SignInScreen(),
        '/sos': (_) => const SosScreen(),
      },
    );
  }
}
