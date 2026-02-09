import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';

class SubjectsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get subjects based on user's stage and grade
  Future<List<SubjectModel>> getSubjectsForUser(
    String stage,
    String grade,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('subjects')
          .where('applicableStages', arrayContains: stage)
          .where('applicableGrades', arrayContains: grade)
          .get();

      return snapshot.docs
          .map(
              (doc) => SubjectModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  // Get all subjects
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('subjects').get();

      return snapshot.docs
          .map(
              (doc) => SubjectModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  // Add sample subjects (run this once to populate Firebase)
  Future<void> addSampleSubjects() async {
    try {
      final subjects = [
        SubjectModel(
          id: '1',
          title: 'Mathematics',
          description: 'Learn Mathematics',
          imageUrl:
              'https://images.unsplash.com/photo-1518611505867-48a0ff305bad?w=500&h=300&fit=crop',
          numberOfTeachers: 12,
          applicableStages: ['prepatory', 'secondary', 'college'],
          applicableGrades: ['One', 'Two', 'Three', 'Four', 'Five'],
          courseCount: 25,
        ),
        SubjectModel(
          id: '2',
          title: 'English Language',
          description: 'Learn English Language',
          imageUrl:
              'https://images.unsplash.com/photo-1546410531-bb4caa6b6e85?w=500&h=300&fit=crop',
          numberOfTeachers: 8,
          applicableStages: ['prepatory', 'secondary', 'college'],
          applicableGrades: ['One', 'Two', 'Three', 'Four', 'Five'],
          courseCount: 18,
        ),
        SubjectModel(
          id: '3',
          title: 'Programming',
          description: 'Learn Programming Basics',
          imageUrl:
              'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&h=300&fit=crop',
          numberOfTeachers: 15,
          applicableStages: ['secondary', 'college'],
          applicableGrades: ['Two', 'Three', 'Four', 'Five'],
          courseCount: 32,
        ),
        SubjectModel(
          id: '4',
          title: 'Science',
          description: 'Learn Science Fundamentals',
          imageUrl:
              'https://images.unsplash.com/photo-1530123482582-a618bc2615dc?w=500&h=300&fit=crop',
          numberOfTeachers: 10,
          applicableStages: ['prepatory', 'secondary'],
          applicableGrades: ['One', 'Two', 'Three'],
          courseCount: 20,
        ),
        SubjectModel(
          id: '5',
          title: 'Web Development',
          description: 'Master Web Development',
          imageUrl:
              'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500&h=300&fit=crop',
          numberOfTeachers: 14,
          applicableStages: ['secondary', 'college'],
          applicableGrades: ['Two', 'Three', 'Four', 'Five'],
          courseCount: 28,
        ),
        SubjectModel(
          id: '6',
          title: 'History',
          description: 'Learn History',
          imageUrl:
              'https://images.unsplash.com/photo-1544716278-ca5e3af4abd8?w=500&h=300&fit=crop',
          numberOfTeachers: 6,
          applicableStages: ['prepatory', 'secondary'],
          applicableGrades: ['One', 'Two', 'Three'],
          courseCount: 15,
        ),
      ];

      for (var subject in subjects) {
        await _firestore
            .collection('subjects')
            .doc(subject.id)
            .set(subject.toMap());
      }

      print('✅ Sample subjects added successfully!');
    } catch (e) {
      print('Error adding subjects: $e');
    }
  }
}
