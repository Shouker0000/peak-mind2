import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../models/teacher_model.dart';
import '../services/teachers_service.dart';
import '../widgets/teacher_card_widget.dart';
import 'teacher_courses_screen.dart';

class TeachersListScreen extends StatefulWidget {
  final SubjectModel subject;

  const TeachersListScreen({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  State<TeachersListScreen> createState() => _TeachersListScreenState();
}

class _TeachersListScreenState extends State<TeachersListScreen> {
  final TeachersService _teachersService = TeachersService();
  List<TeacherModel> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      final teachers =
          await _teachersService.getTeachersBySubject(widget.subject.id);

      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading teachers: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.subject.title} Teachers'),
        backgroundColor: const Color(0xFF142132),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
              ),
            )
          : _teachers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No teachers available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'for this subject',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _teachers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherCoursesScreen(
                              teacher: _teachers[index],
                              subject: widget.subject,
                            ),
                          ),
                        );
                      },
                      child: TeacherCardWidget(
                        teacher: _teachers[index],
                      ),
                    );
                  },
                ),
    );
  }
}
