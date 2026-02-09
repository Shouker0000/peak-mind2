import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../screens/lesson_list_screen.dart';

class CourseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final TeacherModel teacher;

  const CourseListWidget({
    Key? key,
    required this.courses,
    required this.teacher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonListScreen(
                  courseId: course['id'],
                  courseTitle: course['title'] ?? 'Course',
                  teacher: teacher,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Image
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    color: const Color(0xFF25A0DC).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 80,
                    color: Color(0xFF25A0DC),
                  ),
                ),
                // Course Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'] ?? 'Course Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF142132),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course['description'] ?? 'No description',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Enroll Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Enrolled in ${course['title'] ?? 'course'}'),
                                backgroundColor: const Color(0xFF25A0DC),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25A0DC),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Lessons',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
