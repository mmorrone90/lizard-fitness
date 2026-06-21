import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lizard_fitness/models/user_model.dart';
import 'package:lizard_fitness/models/onboarding_profile.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/models/workout.dart';
import 'package:lizard_fitness/models/workout_session.dart';
import 'package:lizard_fitness/models/progress_photo.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Onboarding ─────────────────────────────────────────────────────────────

  Future<OnboardingProfile?> getOnboardingProfile(String uid) async {
    final doc = await _db.collection('onboardingProfiles').doc(uid).get();
    if (!doc.exists) return null;
    return OnboardingProfile.fromFirestore(doc);
  }

  Future<void> saveOnboardingProfile(OnboardingProfile profile) async {
    await _db.collection('onboardingProfiles').doc(profile.userId).set(
      profile.toFirestore(),
      SetOptions(merge: true),
    );
    await _db.collection('users').doc(profile.userId).update({
      'onboardingCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Exercises ──────────────────────────────────────────────────────────────

  Future<List<Exercise>> getExercises() async {
    final snap = await _db.collection('exercises').orderBy('name').get();
    return snap.docs.map(Exercise.fromFirestore).toList();
  }

  Stream<List<Exercise>> watchExercises() {
    return _db.collection('exercises').orderBy('name').snapshots().map(
      (snap) => snap.docs.map(Exercise.fromFirestore).toList(),
    );
  }

  Future<Exercise?> getExercise(String id) async {
    final doc = await _db.collection('exercises').doc(id).get();
    if (!doc.exists) return null;
    return Exercise.fromFirestore(doc);
  }

  // ── Workout Templates ──────────────────────────────────────────────────────

  Future<List<WorkoutTemplate>> getWorkoutTemplates() async {
    final snap = await _db.collection('workoutTemplates').get();
    return snap.docs.map(WorkoutTemplate.fromFirestore).toList();
  }

  Stream<List<WorkoutTemplate>> watchWorkoutTemplates() {
    return _db.collection('workoutTemplates').snapshots().map(
      (snap) => snap.docs.map(WorkoutTemplate.fromFirestore).toList(),
    );
  }

  // ── Custom Workouts ────────────────────────────────────────────────────────

  Stream<List<CustomWorkout>> watchCustomWorkouts(String uid) {
    return _db
        .collection('customWorkouts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CustomWorkout.fromFirestore).toList());
  }

  Future<String> saveCustomWorkout(CustomWorkout workout) async {
    if (workout.id.isEmpty) {
      final ref = await _db.collection('customWorkouts').add(workout.toFirestore());
      return ref.id;
    } else {
      await _db.collection('customWorkouts').doc(workout.id).set(
        workout.toFirestore(),
        SetOptions(merge: true),
      );
      return workout.id;
    }
  }

  Future<void> deleteCustomWorkout(String workoutId) async {
    await _db.collection('customWorkouts').doc(workoutId).delete();
  }

  // ── Workout Sessions ───────────────────────────────────────────────────────

  Stream<List<WorkoutSession>> watchWorkoutSessions(String uid) {
    return _db
        .collection('workoutSessions')
        .where('userId', isEqualTo: uid)
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(WorkoutSession.fromFirestore).toList());
  }

  Future<List<WorkoutSession>> getRecentSessions(String uid, {int limit = 10}) async {
    final snap = await _db
        .collection('workoutSessions')
        .where('userId', isEqualTo: uid)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(WorkoutSession.fromFirestore).toList();
  }

  Future<String> saveWorkoutSession(WorkoutSession session) async {
    if (session.id.isEmpty) {
      final ref = await _db.collection('workoutSessions').add(session.toFirestore());
      return ref.id;
    } else {
      await _db.collection('workoutSessions').doc(session.id).set(
        session.toFirestore(),
        SetOptions(merge: true),
      );
      return session.id;
    }
  }

  // ── Personal Records ───────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getPersonalRecords(String uid) async {
    final snap = await _db
        .collection('personalRecords')
        .where('userId', isEqualTo: uid)
        .orderBy('achievedAt', descending: true)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> savePersonalRecord(String uid, Map<String, dynamic> record) async {
    final existing = await _db
        .collection('personalRecords')
        .where('userId', isEqualTo: uid)
        .where('exerciseId', isEqualTo: record['exerciseId'])
        .where('recordType', isEqualTo: record['recordType'])
        .get();

    final data = {
      ...record,
      'userId': uid,
      'achievedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (existing.docs.isNotEmpty) {
      final current = existing.docs.first.data()['value'];
      if ((record['value'] as num) > (current as num)) {
        await existing.docs.first.reference.update(data);
      }
    } else {
      await _db.collection('personalRecords').add(data);
    }
  }

  // ── Progress Photos ────────────────────────────────────────────────────────

  Stream<List<ProgressPhoto>> watchProgressPhotos(String uid) {
    return _db
        .collection('progressPhotos')
        .where('userId', isEqualTo: uid)
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProgressPhoto.fromFirestore).toList());
  }

  Future<String> saveProgressPhoto(ProgressPhoto photo) async {
    final ref = await _db.collection('progressPhotos').add(photo.toFirestore());
    return ref.id;
  }

  Future<void> deleteProgressPhoto(String photoId) async {
    await _db.collection('progressPhotos').doc(photoId).delete();
  }

  // ── Milestones ─────────────────────────────────────────────────────────────

  Stream<List<Milestone>> watchMilestones(String uid) {
    return _db
        .collection('milestones')
        .where('userId', isEqualTo: uid)
        .orderBy('achievedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Milestone.fromFirestore).toList());
  }

  // ── Gym Challenges ─────────────────────────────────────────────────────────

  Future<List<GymChallenge>> getGymChallenges() async {
    final snap = await _db.collection('gymChallenges').get();
    return snap.docs.map(GymChallenge.fromFirestore).toList();
  }
}
