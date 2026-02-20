import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';

class SubjectsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all subjects (for testing or admin use)
  Future<List<SubjectModel>> getSubjects() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('subjects').get();

      return snapshot.docs
          .map(
              (doc) => SubjectModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get subjects filtered by user stage and grade
  Future<List<SubjectModel>> getSubjectsForUser(
      String stage, String grade) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('subjects')
          .where('applicableStages', arrayContains: stage)
          .get();

      return snapshot.docs
          .map(
              (doc) => SubjectModel.fromMap(doc.data() as Map<String, dynamic>))
          .where((subject) => subject.applicableGrades.contains(grade))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get single subject by ID
  Future<SubjectModel?> getSubject(String subjectId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('subjects').doc(subjectId).get();

      if (doc.exists) {
        return SubjectModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
