import 'package:flutter/material.dart';
import 'package:peak_mind/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String title;
  final String description;
  final String price;
  final String instructor;

  const CourseDetailScreen({
    Key? key,
    required this.courseId,
    required this.title,
    required this.description,
    required this.price,
    required this.instructor,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isEnrolled = false;

  @override
  Widget build(BuildContext context) {
    // Use the correct method call
    User? currentUser = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school, size: 100, color: Colors.blue),
              ),
              const SizedBox(height: 20),
              // Course Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Instructor
              Text(
                'by ${widget.instructor}',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              // Price
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              // Description
              const Text(
                'About this course',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 30),
              // Enroll Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: currentUser != null ? _enrollCourse : null,
                  child: const Text('Enroll Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _enrollCourse() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enrolled successfully!')),
    );
  }
}
