import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'video_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isEnrolled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEnrollment();
  }

  Future<void> _checkEnrollment() async {
    try {
      var currentUser = _authService.currentUser;
      if (currentUser != null) {
        bool enrolled = await _firestoreService.isStudentEnrolled(
          studentId: currentUser.uid,
          courseId: widget.course.id,
        );
        setState(() {
          _isEnrolled = enrolled;
        });
      }
    } catch (e) {
      print('Error checking enrollment: $e');
    }
  }

  Future<void> _enrollCourse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _firestoreService.enrollStudent(
          studentId: currentUser.uid,
          courseId: widget.course.id,
        );
        setState(() {
          _isEnrolled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully enrolled in course!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enrolling: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: 200,
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: widget.course.thumbnailUrl.isNotEmpty
                  ? Image.network(
                      widget.course.thumbnailUrl,
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.course.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'by ${widget.course.instructor}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.course.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.people,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.course.totalStudents.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: AppTheme.secondaryColor,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.course.duration}m',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'About this course',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.course.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightTextColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  CustomButton(
                    label: _isEnrolled ? 'Watch Now' : 'Enroll Now',
                    onPressed: () {
                      if (_isEnrolled) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                VideoPlayerScreen(course: widget.course),
                          ),
                        );
                      } else {
                        _enrollCourse();
                      }
                    },
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
