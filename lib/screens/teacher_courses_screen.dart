import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subject_model.dart';
import '../models/teacher_model.dart';
import '../services/teachers_service.dart';
import '../services/lessons_service.dart';
import '../services/enrollment_service.dart';
import 'lesson_list_screen.dart';

class TeacherCoursesScreen extends StatefulWidget {
  final TeacherModel teacher;
  final SubjectModel subject;

  const TeacherCoursesScreen({
    Key? key,
    required this.teacher,
    required this.subject,
  }) : super(key: key);

  @override
  State<TeacherCoursesScreen> createState() => _TeacherCoursesScreenState();
}

class _TeacherCoursesScreenState extends State<TeacherCoursesScreen> {
  final TeachersService _teachersService = TeachersService();
  final LessonsService _lessonsService = LessonsService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  List<Map<String, dynamic>> _courses = [];
  Set<String> _enrolledCourseIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses =
          await _teachersService.getTeacherCourses(widget.teacher.id);

      final user = FirebaseAuth.instance.currentUser;
      final enrolled = <String>{};
      if (user != null) {
        for (final course in courses) {
          final courseId = course['id'] as String? ?? '';
          if (courseId.isNotEmpty &&
              await _enrollmentService.isEnrolled(user.uid, courseId)) {
            enrolled.add(courseId);
          }
        }
      }

      setState(() {
        _courses = courses;
        _enrolledCourseIds = enrolled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enroll(String courseId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final lessons = await _lessonsService.getLessonsByCourse(courseId);
      await _enrollmentService.enrollInCourse(
          user.uid, courseId, lessons.length);
      setState(() => _enrolledCourseIds.add(courseId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enrolled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enrolling: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoHeader(),
                  _buildAboutSection(),
                  _buildContactInfo(),
                  _buildCoursesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPhotoHeader() {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.teacher.profileImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.black,
                size: 18,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            widget.teacher.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black54,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About the Teacher',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF142132),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.teacher.bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.teacher.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF142132),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.teacher.phoneNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF142132),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection() {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Teacher Courses',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF142132),
            ),
          ),
          const SizedBox(height: 16),
          if (_courses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No courses available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ..._courses.map((course) => _buildCourseCard(course)).toList(),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.network(
              course['coverImage'] ??
                  'https://via.placeholder.com/400x200?text=Course',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF142132),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.subject.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'by ${widget.teacher.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  course['title'] ?? 'Course Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142132),
                  ),
                ),
                const SizedBox(height: 16),
                _buildEnrollButton(course),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollButton(Map<String, dynamic> course) {
    final courseId = course['id'] as String? ?? '';
    final isEnrolled = _enrolledCourseIds.contains(courseId);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (isEnrolled) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonListScreen(
                  courseId: courseId,
                  courseTitle: course['title'] ?? 'Course',
                  teacher: widget.teacher,
                ),
              ),
            );
          } else {
            _enroll(courseId).then((_) {
              if (_enrolledCourseIds.contains(courseId) && mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LessonListScreen(
                      courseId: courseId,
                      courseTitle: course['title'] ?? 'Course',
                      teacher: widget.teacher,
                    ),
                  ),
                );
              }
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnrolled ? const Color(0xFF142132) : const Color(0xFF25A0DC),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          isEnrolled ? 'Continue Learning' : 'Enroll',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
