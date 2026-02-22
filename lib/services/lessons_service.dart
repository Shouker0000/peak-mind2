import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';
import '../utils/constants.dart';

class LessonsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .orderBy('lessonNumber', descending: false)
          .get();

      final lessons = snapshot.docs
          .map((doc) => LessonModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return lessons;
    } catch (e) {
      print('Error getting lessons: $e');
      return [];
    }
  }

  Future<LessonModel?> getLesson(String lessonId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('lessons').doc(lessonId).get();

      if (doc.exists) {
        return LessonModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting lesson: $e');
      return null;
    }
    return null;
  }

  Future<String> createLesson(LessonModel lesson) async {
    try {
      DocumentReference docRef =
          await _firestore.collection('lessons').add(lesson.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating lesson: $e');
      rethrow;
    }
  }

  Future<void> updateLesson(String lessonId, LessonModel lesson) async {
    try {
      await _firestore
          .collection('lessons')
          .doc(lessonId)
          .update(lesson.toMap());
    } catch (e) {
      print('Error updating lesson: $e');
      rethrow;
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).delete();
    } catch (e) {
      print('Error deleting lesson: $e');
      rethrow;
    }
  }

  Future<int> getTotalLessons(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
