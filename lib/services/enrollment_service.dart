import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _enrollmentId(String userId, String courseId) => '${userId}_$courseId';

  Future<void> enrollInCourse(
      String userId, String courseId, int totalLessons) async {
    final docId = _enrollmentId(userId, courseId);
    await _firestore.collection('enrollments').doc(docId).set({
      'userId': userId,
      'courseId': courseId,
      'enrolledAt': FieldValue.serverTimestamp(),
      'lastAccessed': FieldValue.serverTimestamp(),
      'progress': 0.0,
      'completedLessons': 0,
      'totalLessons': totalLessons,
      'completedLessonIds': [],
    });
  }

  Future<bool> isEnrolled(String userId, String courseId) async {
    try {
      final doc = await _firestore
          .collection('enrollments')
          .doc(_enrollmentId(userId, courseId))
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> unenrollFromCourse(String userId, String courseId) async {
    await _firestore
        .collection('enrollments')
        .doc(_enrollmentId(userId, courseId))
        .delete();
  }

  Future<List<String>> getCompletedLessonIds(
      String userId, String courseId) async {
    try {
      final doc = await _firestore
          .collection('enrollments')
          .doc(_enrollmentId(userId, courseId))
          .get();
      if (!doc.exists) return [];
      return List<String>.from(doc.data()?['completedLessonIds'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<void> updateLastVideoPosition(
      String userId, String courseId, String lessonId, int positionSeconds) async {
    final docId = _enrollmentId(userId, courseId);
    try {
      await _firestore.collection('enrollments').doc(docId).update({
        'lastVideoLessonId': lessonId,
        'lastVideoPositionSeconds': positionSeconds,
        'lastAccessed': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // Ignore not-found errors (user not enrolled yet)
      if (e.code != 'not-found') {
        print('Error updating video position: ${e.code} - ${e.message}');
      }
    } catch (e) {
      print('Error updating video position: $e');
    }
  }

  Future<Map<String, dynamic>> getLastVideoPosition(
      String userId, String courseId) async {
    try {
      final doc = await _firestore
          .collection('enrollments')
          .doc(_enrollmentId(userId, courseId))
          .get();
      if (!doc.exists) return {};
      return {
        'lessonId': doc.data()?['lastVideoLessonId'],
        'positionSeconds': doc.data()?['lastVideoPositionSeconds'] ?? 0,
      };
    } on FirebaseException catch (e) {
      print('Error getting video position: ${e.code} - ${e.message}');
      return {};
    } catch (e) {
      print('Error getting video position: $e');
      return {};
    }
  }

  Future<void> markLessonComplete(String userId, String courseId,
      String lessonId, bool isCompleted, int totalLessons) async {
    final docId = _enrollmentId(userId, courseId);
    final docRef = _firestore.collection('enrollments').doc(docId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final data = doc.data()!;
      final completedIds = List<String>.from(data['completedLessonIds'] ?? []);

      if (isCompleted && !completedIds.contains(lessonId)) {
        completedIds.add(lessonId);
      } else if (!isCompleted) {
        completedIds.remove(lessonId);
      }

      final count = completedIds.length;
      final total = totalLessons > 0 ? totalLessons : 1;

      transaction.update(docRef, {
        'completedLessonIds': completedIds,
        'completedLessons': count,
        'totalLessons': totalLessons,
        'progress': count / total,
        'lastAccessed': FieldValue.serverTimestamp(),
      });
    });
  }
}
