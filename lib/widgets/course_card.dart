import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../utils/theme.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isTeacherView;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isTeacherView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            // Thumbnail
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: course.thumbnailUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(course.thumbnailUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: course.thumbnailUrl.isEmpty
                  ? const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.instructor,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${course.totalStudents})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightTextColor,
                            ),
                          ),
                        ],
                      ),
                      if (isTeacherView)
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: onEdit,
                              child: const Text('Edit'),
                            ),
                            PopupMenuItem(
                              onTap: onDelete,
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
