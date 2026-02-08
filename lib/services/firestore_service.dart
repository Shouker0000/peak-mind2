import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== COURSES ====================

  // Create course
  Future<String> createCourse(CourseModel course) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(AppConstants.coursesCollection)
          .add(course.toJson());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all courses
  Future<List<CourseModel>> getAllCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.coursesCollection)
          .get();
      return snapshot.docs
          .map(
            (doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get courses by teacher
  Future<List<CourseModel>> getCoursesByTeacher(String teacherId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.coursesCollection)
          .where('instructorId', isEqualTo: teacherId)
          .get();
      return snapshot.docs
          .map(
            (doc) => CourseModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single course
  Future<CourseModel?> getCourse(String courseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.coursesCollection)
          .doc(courseId)
          .get();

      if (doc.exists) {
        return CourseModel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Update course
  Future<void> updateCourse(String courseId, CourseModel course) async {
    try {
      await _firestore
          .collection(AppConstants.coursesCollection)
          .doc(courseId)
          .update(course.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore
          .collection(AppConstants.coursesCollection)
          .doc(courseId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ENROLLMENTS ====================

  // Enroll student in course
  Future<void> enrollStudent({
    required String studentId,
    required String courseId,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.enrollmentsCollection)
          .doc('${studentId}_$courseId')
          .set({
            'studentId': studentId,
            'courseId': courseId,
            'enrolledAt': Timestamp.now(),
            'progress': 0.0,
          });
    } catch (e) {
      rethrow;
    }
  }

  // Get enrolled courses for student
  Future<List<CourseModel>> getEnrolledCourses(String studentId) async {
    try {
      QuerySnapshot enrollments = await _firestore
          .collection(AppConstants.enrollmentsCollection)
          .where('studentId', isEqualTo: studentId)
          .get();

      List<CourseModel> courses = [];
      for (var doc in enrollments.docs) {
        String courseId = doc['courseId'];
        CourseModel? course = await getCourse(courseId);
        if (course != null) {
          courses.add(course);
        }
      }
      return courses;
    } catch (e) {
      rethrow;
    }
  }

  // Check if student enrolled
  Future<bool> isStudentEnrolled({
    required String studentId,
    required String courseId,
  }) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.enrollmentsCollection)
          .doc('${studentId}_$courseId')
          .get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }
}
