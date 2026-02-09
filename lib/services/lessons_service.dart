import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson_model.dart';

class LessonsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get lessons by course
  Future<List<LessonModel>> getLessonsByCourse(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('courseId', isEqualTo: courseId)
          .orderBy('lessonNumber')
          .get();

      return snapshot.docs
          .map((doc) => LessonModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  // Get single lesson
  Future<LessonModel?> getLesson(String lessonId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('lessons').doc(lessonId).get();

      if (doc.exists) {
        return LessonModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching lesson: $e');
    }
    return null;
  }

  // Create lesson
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

  // Add sample lessons (for testing)
  Future<void> addSampleLessons() async {
    try {
      final lessons = [
        LessonModel(
          id: 'lesson_1',
          courseId: 'course_1',
          title: 'Introduction to Algebra',
          description:
              'Learn the basics of algebra including variables and equations',
          lessonNumber: 1,
          videoUrl: 'dQw4w9WgXcQ', // YouTube video ID
          pdfUrl: 'https://example.com/pdfs/lesson1.pdf',
          durationMinutes: 25,
          createdAt: DateTime.now(),
          isLocked: false,
        ),
        LessonModel(
          id: 'lesson_2',
          courseId: 'course_1',
          title: 'Solving Linear Equations',
          description:
              'Master techniques for solving linear equations step by step',
          lessonNumber: 2,
          videoUrl: 'dQw4w9WgXcQ',
          pdfUrl: 'https://example.com/pdfs/lesson2.pdf',
          durationMinutes: 32,
          createdAt: DateTime.now(),
          isLocked: false,
        ),
        LessonModel(
          id: 'lesson_3',
          courseId: 'course_1',
          title: 'Quadratic Equations',
          description: 'Understanding and solving quadratic equations',
          lessonNumber: 3,
          videoUrl: 'dQw4w9WgXcQ',
          pdfUrl: 'https://example.com/pdfs/lesson3.pdf',
          durationMinutes: 40,
          createdAt: DateTime.now(),
          isLocked: true, // Premium lesson
        ),
      ];

      for (var lesson in lessons) {
        await _firestore
            .collection('lessons')
            .doc(lesson.id)
            .set(lesson.toMap());
      }

      print('✅ Sample lessons added successfully!');
    } catch (e) {
      print('Error adding sample lessons: $e');
    }
  }
}
