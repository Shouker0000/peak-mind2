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
      print('Error fetching teachers: $e');
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
      print('Error fetching teacher: $e');
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
      print('Error fetching teacher courses: $e');
      return [];
    }
  }

  // Add sample teachers (for testing)
  Future<void> addSampleTeachers() async {
    try {
      final teachers = [
        TeacherModel(
          id: 'teacher_1',
          name: 'Dr. Ahmed Mohamed',
          email: 'ahmed@example.com',
          profileImage:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
          bio:
              'Expert mathematician with 10+ years of teaching experience. Passionate about making math fun and understandable for all students.',
          specialization: 'Mathematics',
          subjectIds: ['1', '2', '4'],
          phoneNumber: '+201000000001',
        ),
        TeacherModel(
          id: 'teacher_2',
          name: 'Mrs. Sarah Johnson',
          email: 'sarah@example.com',
          profileImage:
              'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
          bio:
              'English language specialist with expertise in grammar, literature, and conversational skills. Making English learning engaging.',
          specialization: 'English Language',
          subjectIds: ['2', '5'],
          phoneNumber: '+201000000002',
        ),
        TeacherModel(
          id: 'teacher_3',
          name: 'Prof. Hassan Ali',
          email: 'hassan@example.com',
          profileImage:
              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
          bio:
              'Programming expert with industry experience. Teaching web development, algorithms, and best practices in software development.',
          specialization: 'Programming',
          subjectIds: ['3', '5'],
          phoneNumber: '+201000000003',
        ),
        TeacherModel(
          id: 'teacher_4',
          name: 'Dr. Fatima Al-Rashid',
          email: 'fatima@example.com',
          profileImage:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
          bio:
              'Science educator dedicated to making complex concepts simple. Interactive experiments and real-world applications.',
          specialization: 'Science',
          subjectIds: ['4', '6'],
          phoneNumber: '+201000000004',
        ),
      ];

      for (var teacher in teachers) {
        await _firestore
            .collection('teachers')
            .doc(teacher.id)
            .set(teacher.toMap());
      }

      print('✅ Sample teachers added successfully!');
    } catch (e) {
      print('Error adding sample teachers: $e');
    }
  }
}
