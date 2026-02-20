import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

class LessonsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .get();

      final lessons = snapshot.docs
          .map((doc) => LessonModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));

      return lessons;
    } catch (e) {
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
      rethrow;
    }
  }
}
