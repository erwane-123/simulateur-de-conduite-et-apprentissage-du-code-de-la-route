import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_route_flutter/models/test_question.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Questions
  Future<void> uploadQuestion(TestQuestion question) async {
    await _db
        .collection('questions')
        .doc(question.id.toString())
        .set(question.toMap());
  }

  Future<void> seedQuestions(List<TestQuestion> questions) async {
    WriteBatch batch = _db.batch();
    int count = 0;
    for (var q in questions) {
      var docRef = _db.collection('questions').doc(q.id.toString());
      batch.set(docRef, q.toMap());
      count++;
      if (count == 500) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }
    if (count > 0) await batch.commit();
  }

  Stream<List<TestQuestion>> getQuestions() {
    return _db.collection('questions').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => TestQuestion.fromMap(doc.data())).toList());
  }

  Future<List<TestQuestion>> getQuestionsByTheme(String themeId) async {
    var snapshot = await _db
        .collection('questions')
        .where('themeId', isEqualTo: themeId)
        .get();
    return snapshot.docs
        .map((doc) => TestQuestion.fromMap(doc.data()))
        .toList();
  }

  // User Profile
  Future<void> createUserProfile(
      String uid, Map<String, dynamic> profileData) async {
    await _db
        .collection('users')
        .doc(uid)
        .set(profileData, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> updateXp(String uid, int xpToAdd) async {
    await _db.collection('users').doc(uid).update({
      'xp': FieldValue.increment(xpToAdd),
    });
  }

  Future<Map<String, dynamic>?> getUserPermitStats({
    required String uid,
    required String permitCode,
  }) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc(permitCode.toUpperCase())
        .get();

    return doc.data();
  }

  Future<void> saveUserPermitStats({
    required String uid,
    required String permitCode,
    required Map<String, dynamic> stats,
    String? displayName,
  }) async {
    final normalizedPermit = permitCode.toUpperCase();
    final userRef = _db.collection('users').doc(uid);

    await userRef.collection('stats').doc(normalizedPermit).set({
      ...stats,
      'permitCode': normalizedPermit,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await userRef.set({
      if (displayName != null && displayName.trim().isNotEmpty)
        'pseudo': displayName.trim(),
      'lastPermitCode': normalizedPermit,
      'xp': stats['xp'] ?? 0,
      'level': stats['level'] ?? 1,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('leaderboard').doc(uid).set({
      'uid': uid,
      'pseudo': (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : 'Utilisateur',
      'permitCode': normalizedPermit,
      'xp': stats['xp'] ?? 0,
      'level': stats['level'] ?? 1,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> leaderboardStream({int limit = 30}) {
    return _db
        .collection('leaderboard')
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(),
              };
            }).toList());
  }

  Future<void> saveSelectedPermit({
    required String uid,
    required String permitCode,
  }) async {
    await _db.collection('users').doc(uid).set({
      'selectedPermitCode': permitCode.toUpperCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveCandidateProfile({
    required String uid,
    required Map<String, dynamic> profile,
  }) async {
    await _db.collection('users').doc(uid).set({
      'candidateProfile': profile,
      'candidateProfileUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveUserThemeProgress({
    required String uid,
    required String permitCode,
    required String themeId,
    required double progress,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('stats')
        .doc(permitCode.toUpperCase())
        .set({
      'permitCode': permitCode.toUpperCase(),
      'themeProgress': {themeId: progress},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
