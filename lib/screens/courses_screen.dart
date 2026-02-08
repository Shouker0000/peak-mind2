import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CourseCard(
              title: 'Flutter Basics',
              description: 'Learn Flutter from scratch',
              price: '\$29.99',
              instructor: 'John Doe',
            ),
            CourseCard(
              title: 'Firebase Integration',
              description: 'Master Firebase with Flutter',
              price: '\$39.99',
              instructor: 'Jane Smith',
            ),
            CourseCard(
              title: 'UI Design',
              description: 'Create beautiful UIs',
              price: '\$24.99',
              instructor: 'Mike Johnson',
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String instructor;

  const CourseCard({
    Key? key,
    required this.title,
    required this.description,
    required this.price,
    required this.instructor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(description, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'by $instructor',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enrolled successfully!')),
                  );
                },
                child: const Text('Enroll Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
