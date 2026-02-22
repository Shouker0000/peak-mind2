import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class AdminCreateCourseScreen extends StatefulWidget {
  const AdminCreateCourseScreen({Key? key}) : super(key: key);

  @override
  State<AdminCreateCourseScreen> createState() =>
      _AdminCreateCourseScreenState();
}

class _AdminCreateCourseScreenState extends State<AdminCreateCourseScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _coverImageUrlController;

  // Dropdowns
  String? _selectedSubjectId;
  String? _selectedSubjectTitle;
  String? _selectedTeacherId;
  String? _selectedTeacherName;

  // Data lists
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _allTeachers = [];
  List<Map<String, dynamic>> _filteredTeachers = [];

  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _coverImageUrlController = TextEditingController();
    _loadSubjectsAndTeachers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _coverImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjectsAndTeachers() async {
    try {
      print('Loading subjects and teachers...');

      // Fetch subjects from subjects collection
      QuerySnapshot subjectsSnapshot =
          await _firestore.collection('subjects').get();

      print('✅ Subjects fetched: ${subjectsSnapshot.docs.length} documents');

      if (subjectsSnapshot.docs.isEmpty) {
        print('⚠️ WARNING: No subjects found in database!');
      }

      // Fetch teachers from teachers collection
      QuerySnapshot teachersSnapshot =
          await _firestore.collection('teachers').get();

      print('✅ Teachers fetched: ${teachersSnapshot.docs.length} documents');

      if (teachersSnapshot.docs.isEmpty) {
        print('⚠️ WARNING: No teachers found in database!');
      }

      setState(() {
        // Map subjects - remove duplicates, use 'title' field
        final subjectMap = <String, Map<String, dynamic>>{};

        for (var doc in subjectsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final subjectId = doc.id;

          // Only add if not already added (removes duplicates)
          if (!subjectMap.containsKey(subjectId)) {
            subjectMap[subjectId] = {
              'id': subjectId,
              'title': data['title'] ?? data['name'] ?? 'Unknown Subject',
              'imageUrl': data['imageUrl'],
              'description': data['description'],
              ...data
            };
          }
        }

        _subjects = subjectMap.values.toList();

        print('✅ Mapped ${_subjects.length} unique subjects');
        _subjects
            .forEach((s) => print('  - ID: ${s['id']}, Title: ${s['title']}'));

        // Map teachers - validate and remove duplicates
        final teacherMap = <String, Map<String, dynamic>>{};

        for (var doc in teachersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final teacherId = doc.id;

          if (!teacherMap.containsKey(teacherId)) {
            // Clean up subjectIds - remove duplicates
            List<dynamic> subjectIds = data['subjectIds'] ?? [];
            List<String> uniqueSubjectIds =
                subjectIds.map((s) => s.toString()).toSet().toList();

            if (subjectIds.length != uniqueSubjectIds.length) {
              print('⚠️ Teacher $teacherId had duplicate subjects, cleaned up');
            }

            teacherMap[teacherId] = {
              'id': teacherId,
              'name': data['name'] ?? 'Unknown Teacher',
              'specialization': data['specialization'],
              'email': data['email'],
              'subjectIds': uniqueSubjectIds, // Use cleaned list
              ...data
            };
          }
        }

        _allTeachers = teacherMap.values.toList();
        print('✅ Mapped ${_allTeachers.length} unique teachers');
        _allTeachers.forEach((t) {
          print(
              '  - ID: ${t['id']}, Name: ${t['name']}, Subjects: ${t['subjectIds']}');
        });

        _isLoadingData = false;
      });
    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Firebase Error: ${e.code}\n${e.message}\n\n'
              'Make sure subjects and teachers collections exist in Firestore.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() => _isLoadingData = false);
    } catch (e) {
      print('❌ General Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e\n\n'
              'Make sure:\n'
              '1. Subjects collection exists\n'
              '2. Teachers collection exists\n'
              '3. Firebase rules allow read access',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() => _isLoadingData = false);
    }
  }

  // Filter teachers based on selected subject
  void _filterTeachersBySubject(String subjectId) {
    print('Filtering teachers for subject: $subjectId');

    // Use a Set to store unique teacher IDs (removes duplicates)
    final uniqueTeacherIds = <String>{};
    List<Map<String, dynamic>> filtered = [];

    for (var teacher in _allTeachers) {
      List<dynamic> subjectIds = teacher['subjectIds'] ?? [];

      print('  Teacher: ${teacher['name']}, Subjects: $subjectIds');

      // Check if teacher teaches this subject
      if (subjectIds.contains(subjectId)) {
        String teacherId = teacher['id'];

        // Only add if not already added (removes duplicates)
        if (!uniqueTeacherIds.contains(teacherId)) {
          uniqueTeacherIds.add(teacherId);
          filtered.add(teacher);
        }
      }
    }

    print('  Found ${filtered.length} unique teachers for this subject');
    filtered.forEach((t) => print('    - ${t['name']} (${t['id']})'));

    setState(() {
      _filteredTeachers = filtered;
      _selectedTeacherId = null; // Reset teacher selection
      _selectedTeacherName = null;
    });
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSubjectId == null || _selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select subject and teacher'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generate course ID
      String courseId = 'course_${DateTime.now().millisecondsSinceEpoch}';

      // Get today's date in ISO format
      String createdAt = DateTime.now().toIso8601String();

      // Create course document
      await _firestore
          .collection(AppConstants.coursesCollection)
          .doc(courseId)
          .set({
        'id': courseId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'coverImage': _coverImageUrlController.text.trim(),
        'createdAt': createdAt,
        'subject': _selectedSubjectTitle,
        'subjectId': _selectedSubjectId,
        'teacherId': _selectedTeacherId,
        'teacher': _selectedTeacherName,
        'enrolledStudents': 0,
        'rating': 0.0,
        'price': '0',
        'duration': '0',
        'createdBy': _auth.currentUser!.uid,
        'isPublished': true,
        'lessons': [],
        'updatedAt': createdAt,
      });

      // Log activity
      await _firestore.collection(AppConstants.activityLogsCollection).add({
        'userId': _auth.currentUser!.uid,
        'action': 'course_created',
        'details': 'New course created: ${_titleController.text.trim()}',
        'metadata': {
          'courseId': courseId,
          'teacherId': _selectedTeacherId,
          'subjectId': _selectedSubjectId,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh parent
      }
    } catch (e) {
      print('Error creating course: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF142132),
        title: const Text(
          'Create New Course',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF25A0DC)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF142132),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Course Title *',
                        hintText: 'e.g., Algebra Basics',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter course title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        hintText: 'Course description...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cover Image URL
                    TextFormField(
                      controller: _coverImageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Cover Image URL *',
                        hintText: 'https://example.com/image.jpg',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.image),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cover image URL';
                        }
                        if (!value.startsWith('http')) {
                          return 'Please enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject Dropdown
                    Text(
                      'Subject *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF142132),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_subjects.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'No subjects available. Please add subjects to the database first.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubjectId,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          hint: const Text('Select a subject'),
                          isExpanded: true,
                          items: _subjects.map((subject) {
                            return DropdownMenuItem<String>(
                              value: subject['id'],
                              child: Text(
                                subject['title'] ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSubjectId = value;
                                // Find the title for selected subject
                                final subject = _subjects.firstWhere(
                                  (s) => s['id'] == value,
                                  orElse: () => {},
                                );
                                _selectedSubjectTitle = subject['title'];
                              });

                              // Filter teachers by subject
                              _filterTeachersBySubject(value);
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subject';
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Teacher Dropdown (filtered by selected subject)
                    Text(
                      'Teacher *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF142132),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedSubjectId == null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Text(
                          'Please select a subject first to see available teachers.',
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    else if (_filteredTeachers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'No teachers available for this subject. Please assign teachers to this subject first.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedTeacherId,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          hint: const Text('Select a teacher'),
                          isExpanded: true,
                          items: _filteredTeachers
                              .map((teacher) {
                                // Make sure value is not null and unique
                                final teacherId = teacher['id'] ?? '';
                                final teacherName =
                                    teacher['name'] ?? 'Unknown';

                                if (teacherId.isEmpty) {
                                  print(
                                      '⚠️ WARNING: Teacher has no ID - ${teacher}');
                                  return null;
                                }

                                return DropdownMenuItem<String>(
                                  value: teacherId,
                                  child: Text(
                                    teacherName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              })
                              .whereType<
                                  DropdownMenuItem<
                                      String>>() // Remove null items
                              .toList(),
                          onChanged: (value) {
                            if (value != null && value.isNotEmpty) {
                              setState(() {
                                _selectedTeacherId = value;
                                // Find the name for selected teacher
                                final teacher = _filteredTeachers.firstWhere(
                                  (t) => t['id'] == value,
                                  orElse: () => {},
                                );
                                _selectedTeacherName = teacher['name'];
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a teacher';
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Course ID (auto-generated, display only)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Course ID (Auto-generated)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'course_${DateTime.now().millisecondsSinceEpoch}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF142132),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Created At (today's date, display only)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Created At',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF142132),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25A0DC),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Course',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
