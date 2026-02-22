import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/teacher_model.dart';
import '../models/lesson_model.dart';
import '../services/lessons_service.dart';
import '../services/enrollment_service.dart';
import '../widgets/lesson_card_widget.dart';
import 'lesson_player_screen.dart';

class LessonListScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final TeacherModel teacher;

  const LessonListScreen({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.teacher,
  }) : super(key: key);

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final LessonsService _lessonsService = LessonsService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  List<LessonModel> _lessons = [];
  Set<String> _completedLessonIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lessons = await _lessonsService.getLessonsByCourse(widget.courseId);
      final user = FirebaseAuth.instance.currentUser;
      Set<String> completed = {};
      if (user != null) {
        final ids = await _enrollmentService.getCompletedLessonIds(
            user.uid, widget.courseId);
        completed = ids.toSet();
      }
      setState(() {
        _lessons = lessons;
        _completedLessonIds = completed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLesson(String lessonId, bool isCompleted) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      if (isCompleted) {
        _completedLessonIds.add(lessonId);
      } else {
        _completedLessonIds.remove(lessonId);
      }
    });
    await _enrollmentService.markLessonComplete(
        user.uid, widget.courseId, lessonId, isCompleted, _lessons.length);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _completedLessonIds.length;
    final totalCount = _lessons.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: const Color(0xFF142132),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
              ),
            )
          : _lessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No lessons available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildProgressHeader(completedCount, totalCount, progress),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _lessons.length,
                        itemBuilder: (context, index) {
                          final lesson = _lessons[index];
                          final isCompleted =
                              _completedLessonIds.contains(lesson.id);
                          return LessonCardWidget(
                            lesson: lesson,
                            isCompleted: isCompleted,
                            onCompletionToggled: (value) =>
                                _toggleLesson(lesson.id, value),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonPlayerScreen(
                                    lesson: lesson,
                                    isCompleted: isCompleted,
                                    onCompletionToggled: (value) =>
                                        _toggleLesson(lesson.id, value),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProgressHeader(int completed, int total, double progress) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                '$completed of $total lessons completed',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF25A0DC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF25A0DC)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% complete',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
