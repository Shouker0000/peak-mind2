import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';
import '../services/subjects_service.dart';
import '../services/teachers_service.dart';
import '../models/teacher_model.dart';
import 'teacher_list_screen.dart';

class CoursesScreen extends StatefulWidget {
  final UserModel userModel;

  const CoursesScreen({Key? key, required this.userModel}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final SubjectsService _subjectsService = SubjectsService();
  final TeachersService _teachersService = TeachersService();

  List<SubjectModel> _subjects = [];
  Map<String, int> _teacherCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final subjects = await _subjectsService.getSubjectsForUser(
        widget.userModel.stage,
        widget.userModel.grade,
      );

      final teachers = await _teachersService.getAllTeachers();

      final counts = <String, int>{};
      for (var subject in subjects) {
        counts[subject.id] =
            teachers.where((t) => t.subjectIds.contains(subject.id)).length;
      }

      setState(() {
        _subjects = subjects;
        _teacherCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Courses'),
        backgroundColor: const Color(0xFF142132),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
              ),
            )
          : _subjects.isEmpty
              ? const Center(child: Text('No courses available'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        0.8, // Slightly reduced to prevent overflow
                  ),
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final teacherCount = _teacherCounts[subject.id] ?? 0;
                    return _buildSubjectCard(subject, teacherCount);
                  },
                ),
    );
  }

  Widget _buildSubjectCard(SubjectModel subject, int teacherCount) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeachersListScreen(subject: subject),
          ),
        );
      },
      child: Container(
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
            // Image Section with Flexible to prevent overflow
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF25A0DC).withOpacity(0.1),
                  // Fetch image from Firebase using imageUrl field
                  child: subject.imageUrl != null &&
                          subject.imageUrl!.isNotEmpty
                      ? Image.network(
                          subject.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                _getSubjectIcon(subject.title),
                                size: 50,
                                color: const Color(0xFF25A0DC),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF25A0DC),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            _getSubjectIcon(subject.title),
                            size: 50,
                            color: const Color(0xFF25A0DC),
                          ),
                        ),
                ),
              ),
            ),
            // Text Section with Flexible
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center vertically
                  children: [
                    Text(
                      subject.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF142132),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$teacherCount Teachers',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF25A0DC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.applicableGrades.length} Grades',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSubjectIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('math')) return Icons.calculate;
    if (lower.contains('english')) return Icons.language;
    if (lower.contains('science')) return Icons.science;
    if (lower.contains('programming')) return Icons.computer;
    if (lower.contains('history')) return Icons.history;
    return Icons.school;
  }
}
