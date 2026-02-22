import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject_model.dart';
import '../services/subjects_service.dart';
import '../services/teachers_service.dart';
import '../services/enrollment_service.dart';
import '../models/teacher_model.dart';
import 'teacher_list_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final SubjectsService _subjectsService = SubjectsService();
  final TeachersService _teachersService = TeachersService();
  final EnrollmentService _enrollmentService = EnrollmentService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<SubjectModel> _subjects = [];
  List<SubjectModel> _filteredSubjects = [];
  Map<String, int> _teacherCounts = {};
  bool _isLoading = true;
  String _userStage = 'secondary';
  String _userGrade = '10';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applySearch();
    });
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredSubjects = List.from(_subjects);
    } else {
      _filteredSubjects = _subjects
          .where((s) => s.title.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get user document from Firestore
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _userStage = userData['stage'] ?? 'secondary';
        _userGrade = userData['grade'] ?? '10';
      }

      _loadCourses();
    } catch (e) {
      print('Error loading user data: $e');
      _loadCourses();
    }
  }

  Future<void> _loadCourses() async {
    try {
      final subjects = await _subjectsService.getSubjectsForUser(
        _userStage,
        _userGrade,
      );

      final teachers = await _teachersService.getAllTeachers();

      final counts = <String, int>{};
      for (var subject in subjects) {
        counts[subject.id] =
            teachers.where((t) => t.subjectIds.contains(subject.id)).length;
      }

      setState(() {
        _subjects = subjects;
        _filteredSubjects = List.from(subjects);
        _teacherCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Courses', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF142132),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF142132),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
                    ),
                  )
                : _filteredSubjects.isEmpty
                    ? const Center(child: Text('No courses found'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = _filteredSubjects[index];
                          final teacherCount =
                              _teacherCounts[subject.id] ?? 0;
                          return _buildSubjectCard(subject, teacherCount);
                        },
                      ),
          ),
        ],
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
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF25A0DC).withOpacity(0.1),
                  child:
                      subject.imageUrl != null && subject.imageUrl!.isNotEmpty
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
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
