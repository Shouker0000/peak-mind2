import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_model.dart';

class TeachersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get teachers by subject
  Future<List<TeacherModel>> getTeachersBySubject(String subjectId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('teachers')
          .where('subjectIds', arrayContains: subjectId)
          .get();

      return snapshot.docs
          .map(
              (doc) => TeacherModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get ALL teachers (for counting)
  Future<List<TeacherModel>> getAllTeachers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('teachers').get();

      return snapshot.docs
          .map(
              (doc) => TeacherModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get single teacher
  Future<TeacherModel?> getTeacher(String teacherId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('teachers').doc(teacherId).get();

      if (doc.exists) {
        return TeacherModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // Get teacher's courses
  Future<List<Map<String, dynamic>>> getTeacherCourses(String teacherId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      return [];
    }
  }
}
