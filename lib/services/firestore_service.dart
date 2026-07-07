import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/check_in.dart';
import '../models/sober_attempt.dart';
import '../models/user_profile.dart';

/// All Firestore reads/writes for one signed-in user.
///
/// Layout (everything user-scoped, matching the security rules):
///   users/{uid}                     profile + settings
///   users/{uid}/attempts/{autoId}   challenge attempts (one active at most)
///   users/{uid}/checkins/{yyyy-MM-dd}  daily check-ins
class FirestoreService {
  FirestoreService(this._db, this.uid);

  final FirebaseFirestore _db;
  final String uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> get _attempts =>
      _userDoc.collection('attempts');
  CollectionReference<Map<String, dynamic>> get _checkins =>
      _userDoc.collection('checkins');

  // ---- Profile ----

  Stream<UserProfile> watchProfile() =>
      _userDoc.snapshots().map(UserProfile.fromDoc);

  Future<void> saveProfile(UserProfile profile) =>
      _userDoc.set(profile.toMap(), SetOptions(merge: true));

  // ---- Attempts ----

  Stream<SoberAttempt?> watchActiveAttempt() => _attempts
      .where('endedAt', isNull: true)
      .limit(1)
      .snapshots()
      .map((snap) =>
          snap.docs.isEmpty ? null : SoberAttempt.fromDoc(snap.docs.first));

  Stream<List<SoberAttempt>> watchAllAttempts() => _attempts
      .orderBy('startDate', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(SoberAttempt.fromDoc).toList());

  Future<void> startAttempt(DateTime startDate, {int goalDays = 30}) async {
    // Close any stray active attempt first so there's only ever one.
    final active = await _attempts.where('endedAt', isNull: true).get();
    final batch = _db.batch();
    for (final doc in active.docs) {
      batch.update(doc.reference, {
        'endedAt': FieldValue.serverTimestamp(),
        'endReason': 'reset',
      });
    }
    batch.set(_attempts.doc(), {
      'startDate': Timestamp.fromDate(startDate),
      'goalDays': goalDays,
      'endedAt': null,
      'endReason': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> endAttempt(String attemptId, {required String reason}) =>
      _attempts.doc(attemptId).update({
        'endedAt': FieldValue.serverTimestamp(),
        'endReason': reason,
      });

  /// Compassionate reset: closes the current attempt and immediately starts
  /// a fresh one dated [newStart] (usually today).
  Future<void> resetAttempt(String attemptId, DateTime newStart) async {
    final batch = _db.batch();
    batch.update(_attempts.doc(attemptId), {
      'endedAt': FieldValue.serverTimestamp(),
      'endReason': 'reset',
    });
    batch.set(_attempts.doc(), {
      'startDate': Timestamp.fromDate(newStart),
      'goalDays': 30,
      'endedAt': null,
      'endReason': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> updateStartDate(String attemptId, DateTime startDate) =>
      _attempts.doc(attemptId).update({
        'startDate': Timestamp.fromDate(startDate),
      });

  // ---- Check-ins ----

  Stream<CheckIn?> watchCheckIn(String dateKey) =>
      _checkins.doc(dateKey).snapshots().map(
          (doc) => doc.exists ? CheckIn.fromDoc(doc) : null);

  Stream<List<CheckIn>> watchRecentCheckIns({int limit = 30}) => _checkins
      .orderBy(FieldPath.documentId, descending: true)
      .limit(limit)
      .snapshots()
      .map((snap) => snap.docs.map(CheckIn.fromDoc).toList());

  Future<void> saveCheckIn(CheckIn checkIn) =>
      _checkins.doc(checkIn.date).set(checkIn.toMap(), SetOptions(merge: true));
}
