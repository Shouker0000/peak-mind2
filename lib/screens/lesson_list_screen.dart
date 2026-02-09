import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../models/lesson_model.dart';
import '../services/lessons_service.dart';
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
  List<LessonModel> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final lessons = await _lessonsService.getLessonsByCourse(widget.courseId);
      setState(() {
        _lessons = lessons;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading lessons: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lessons: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25A0DC)),
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
                      Text(
                        'No lessons available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    return LessonCardWidget(
                      lesson: _lessons[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonPlayerScreen(
                              lesson: _lessons[index],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
