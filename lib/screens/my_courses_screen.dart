import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../screens/lesson_list_screen.dart';
import '../models/teacher_model.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _enrolledCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEnrolledCourses();
  }

  Future<void> _loadEnrolledCourses() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get enrollments for current user
      final enrollmentSnapshot = await _firestore
          .collection('enrollments')
          .where('userId', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> courses = [];

      for (var doc in enrollmentSnapshot.docs) {
        final enrollmentData = doc.data();
        final courseId = enrollmentData['courseId'];
        final progress = enrollmentData['progress'] ?? 0.0;
        final completedLessons = enrollmentData['completedLessons'] ?? 0;
        final totalLessons = enrollmentData['totalLessons'] ?? 1;

        // Get course details
        final courseDoc =
            await _firestore.collection('courses').doc(courseId).get();
        if (courseDoc.exists) {
          final courseData = courseDoc.data()!;

          // Get teacher details
          final teacherId = courseData['teacherId'];
          TeacherModel? teacher;
          if (teacherId != null) {
            final teacherDoc =
                await _firestore.collection('teachers').doc(teacherId).get();
            if (teacherDoc.exists) {
              teacher = TeacherModel.fromMap(teacherDoc.data()!);
            }
          }

          courses.add({
            'enrollmentId': doc.id,
            'courseId': courseId,
            'title': courseData['title'] ?? 'Untitled Course',
            'description': courseData['description'] ?? '',
            'coverImage': courseData['coverImage'] ?? '',
            'teacher': teacher,
            'progress': progress,
            'completedLessons': completedLessons,
            'totalLessons': totalLessons,
            'lastAccessed': enrollmentData['lastAccessed'],
          });
        }
      }

      setState(() {
        _enrolledCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading enrolled courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enrollInSampleCourse() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create enrollment for course_1
      await _firestore.collection('enrollments').add({
        'userId': user.uid,
        'courseId': 'course_1',
        'progress': 0.35,
        'completedLessons': 1,
        'totalLessons': 3,
        'enrolledAt': DateTime.now().toIso8601String(),
        'lastAccessed': DateTime.now().toIso8601String(),
      });

      _loadEnrolledCourses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enrolled in course!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: const Color(0xFF142132),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
              ),
            )
          : _enrolledCourses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No courses yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Start learning by enrolling in a course',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _enrollInSampleCourse,
                        icon: const Icon(Icons.add),
                        label: const Text('Enroll in Sample Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25A0DC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEnrolledCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _enrolledCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(_enrolledCourses[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final progress = course['progress'] ?? 0.0;
    final completedLessons = course['completedLessons'] ?? 0;
    final totalLessons = course['totalLessons'] ?? 1;
    final teacher = course['teacher'] as TeacherModel?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.network(
              course['coverImage'] ??
                  'https://via.placeholder.com/400x200?text=Course',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  color: const Color(0xFF25A0DC).withOpacity(0.1),
                  child: const Icon(
                    Icons.school,
                    size: 60,
                    color: Color(0xFF25A0DC),
                  ),
                );
              },
            ),
          ),

          // Course Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  course['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142132),
                  ),
                ),
                const SizedBox(height: 4),

                // Teacher Name
                if (teacher != null)
                  Text(
                    'by ${teacher.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 16),

                // Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF25A0DC),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF25A0DC)),
                  ),
                ),
                const SizedBox(height: 8),

                // Lessons Count
                Text(
                  '$completedLessons of $totalLessons lessons completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 16),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (teacher != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonListScreen(
                              courseId: course['courseId'],
                              courseTitle: course['title'],
                              teacher: teacher,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Continue Learning'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25A0DC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
