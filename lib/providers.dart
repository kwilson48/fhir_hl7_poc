import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'models/check_in.dart';
import 'models/sober_attempt.dart';
import 'models/user_profile.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(FirebaseAuth.instance));

final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authServiceProvider).authStateChanges);

/// Null when signed out.
final firestoreServiceProvider = Provider<FirestoreService?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return null;
  return FirestoreService(FirebaseFirestore.instance, user.uid);
});

final profileProvider = StreamProvider<UserProfile?>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  if (service == null) return Stream.value(null);
  return service.watchProfile();
});

final activeAttemptProvider = StreamProvider<SoberAttempt?>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  if (service == null) return Stream.value(null);
  return service.watchActiveAttempt();
});

final allAttemptsProvider = StreamProvider<List<SoberAttempt>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  if (service == null) return Stream.value(const []);
  return service.watchAllAttempts();
});

/// Local date key for "today", e.g. '2026-07-07'.
String todayKey([DateTime? now]) =>
    DateFormat('yyyy-MM-dd').format(now ?? DateTime.now());

final todaysCheckInProvider = StreamProvider<CheckIn?>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  if (service == null) return Stream.value(null);
  return service.watchCheckIn(todayKey());
});

final recentCheckInsProvider = StreamProvider<List<CheckIn>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  if (service == null) return Stream.value(const []);
  return service.watchRecentCheckIns();
});

/// Total alcohol-free days across all attempts (lifetime stat that never
/// resets, so a slip never zeroes out real progress).
final lifetimeDaysProvider = Provider<int>((ref) {
  final attempts = ref.watch(allAttemptsProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  var total = 0;
  for (final a in attempts) {
    total += a.daysIn(now);
  }
  return total;
});
