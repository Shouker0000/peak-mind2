import 'package:flutter/material.dart';
import 'package:peak_mind/utils/theme.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Enrolled courses list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://via.placeholder.com/400x150?text=Course+${index + 1}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Title ${index + 1}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Learn amazing skills in this comprehensive course',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.65,
                                minHeight: 8,
                                backgroundColor: AppTheme.borderColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('65% Complete'),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Continue Learning'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
