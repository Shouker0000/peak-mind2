import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peak_mind/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditCourseScreen extends StatefulWidget {
  final String? courseId;
  final String? title;
  final String? description;
  final String? price;

  const AddEditCourseScreen({
    Key? key,
    this.courseId,
    this.title,
    this.description,
    this.price,
  }) : super(key: key);

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      _titleController.text = widget.title!;
      _descriptionController.text = widget.description!;
      _priceController.text = widget.price!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use the correct method call
    User? currentUser = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseId == null ? 'Add Course' : 'Edit Course'),
      ),
      body: currentUser == null
          ? const Center(
              child: Text('Please login first'),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Course Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Course Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        hintText: 'Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveCourse,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(widget.courseId == null
                                ? 'Create Course'
                                : 'Update Course'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _saveCourse() async {
    String title = _titleController.text.trim();
    String description = _descriptionController.text.trim();
    String price = _priceController.text.trim();

    if (title.isEmpty || description.isEmpty || price.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    User? currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      _showError('Please login first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.courseId == null) {
        // Create new course
        await FirebaseFirestore.instance.collection('courses').add({
          'title': title,
          'description': description,
          'price': price,
          'instructor': currentUser.email,
          'createdBy': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showSuccess('Course created successfully!');
      } else {
        // Update existing course
        await FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .update({
          'title': title,
          'description': description,
          'price': price,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        _showSuccess('Course updated successfully!');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
