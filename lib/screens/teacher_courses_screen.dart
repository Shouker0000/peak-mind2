import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../models/teacher_model.dart';
import '../services/teachers_service.dart';
import '../widgets/teacher_profile_widget.dart';
import '../widgets/course_list_widget.dart';

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
  List<Map<String, dynamic>> _courses = [];
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
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25A0DC)),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Teacher Profile Header
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: const Color(0xFF142132),
                  flexibleSpace: FlexibleSpaceBar(
                    background: TeacherProfileWidget(
                      teacher: widget.teacher,
                    ),
                  ),
                ),
                // Courses List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0 && _courses.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No courses available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return CourseListWidget(
                          courses: _courses,
                          teacher: widget.teacher,
                        );
                      },
                      childCount: _courses.isEmpty ? 1 : _courses.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
