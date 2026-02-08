import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/theme.dart';

class AddEditCourseScreen extends StatefulWidget {
  final CourseModel? course;

  const AddEditCourseScreen({
    Key? key,
    this.course,
  }) : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _thumbnailUrlController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  final TextEditingController _totalStudentsController =
      TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title;
      _descriptionController.text = widget.course!.description;
      _instructorController.text = widget.course!.instructor;
      _videoUrlController.text = widget.course!.videoUrl;
      _thumbnailUrlController.text = widget.course!.thumbnailUrl;
      _categoryController.text = widget.course!.category;
      _durationController.text = widget.course!.duration.toString();
      _ratingController.text = widget.course!.rating.toString();
      _totalStudentsController.text = widget.course!.totalStudents.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    _ratingController.dispose();
    _totalStudentsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var currentUser = _authService.currentUser;
      if (currentUser != null) {
        CourseModel course = CourseModel(
          id: widget.course?.id ?? '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          instructor: _instructorController.text.trim(),
          instructorId: currentUser.uid,
          thumbnailUrl: _thumbnailUrlController.text.trim(),
          videoUrl: _videoUrlController.text.trim(),
          category: _categoryController.text.trim(),
          duration: int.parse(_durationController.text),
          rating: double.parse(_ratingController.text),
          totalStudents: int.parse(_totalStudentsController.text),
          createdAt: widget.course?.createdAt ?? DateTime.now(),
        );

        if (widget.course == null) {
          // Create new course
          await _firestoreService.createCourse(course);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Update existing course
          await _firestoreService.updateCourse(
            widget.course!.id,
            course,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Course updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
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
        title: Text(
          widget.course == null ? 'Add Course' : 'Edit Course',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  label: 'Course Title',
                  controller: _titleController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Instructor Name',
                  controller: _instructorController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Instructor name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'YouTube Video URL or Video ID',
                  controller: _videoUrlController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Video URL is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Thumbnail Image URL',
                  controller: _thumbnailUrlController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Category',
                  controller: _categoryController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Duration (minutes)',
                  controller: _durationController,
                  inputType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Duration is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Rating (0-5)',
                  controller: _ratingController,
                  inputType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Total Students',
                  controller: _totalStudentsController,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  label: widget.course == null
                      ? 'Create Course'
                      : 'Update Course',
                  onPressed: _saveCourse,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
