import 'package:flutter/material.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/course_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'add_edit_course_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late UserModel _currentUser;
  List<CourseModel> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      UserModel? userData = await _authService.getCurrentUserData();
      if (userData != null) {
        setState(() {
          _currentUser = userData;
        });

        // Load courses based on role
        if (userData.role == AppConstants.roleTeacher) {
          List<CourseModel> courses = await _firestoreService
              .getCoursesByTeacher(userData.id);
          setState(() {
            _courses = courses;
            _isLoading = false;
          });
        } else {
          List<CourseModel> courses = await _firestoreService.getAllCourses();
          setState(() {
            _courses = courses;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      await _firestoreService.deleteCourse(courseId);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting course: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/splash', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentUser.role == AppConstants.roleTeacher
            ? const Text('My Courses')
            : const Text('Courses'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: _logout,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentUser.role == AppConstants.roleTeacher
          ? FloatingActionButton(
              backgroundColor: AppTheme.primaryColor,
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const AddEditCourseScreen(),
                      ),
                    )
                    .then((_) {
                      _loadData();
                    });
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _courses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentUser.role == AppConstants.roleTeacher
                        ? 'No courses yet'
                        : 'No courses available',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                CourseModel course = _courses[index];
                return CourseCard(
                  course: course,
                  isTeacherView: _currentUser.role == AppConstants.roleTeacher,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailScreen(course: course),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditCourseScreen(course: course),
                          ),
                        )
                        .then((_) {
                          _loadData();
                        });
                  },
                  onDelete: () {
                    _deleteCourse(course.id);
                  },
                );
              },
            ),
    );
  }
}
