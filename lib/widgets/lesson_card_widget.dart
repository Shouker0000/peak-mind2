import 'package:flutter/material.dart';
import '../models/lesson_model.dart';

class LessonCardWidget extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onTap;
  final bool isCompleted;
  final ValueChanged<bool>? onCompletionToggled;

  const LessonCardWidget({
    Key? key,
    required this.lesson,
    required this.onTap,
    this.isCompleted = false,
    this.onCompletionToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF25A0DC).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF25A0DC).withOpacity(0.4)
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Lesson Number Badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : const Color(0xFF25A0DC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : Text(
                          'L${lesson.lessonNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Lesson Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.grey[600]
                                  : const Color(0xFF142132),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lesson.isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 12,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Premium',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.durationMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.picture_as_pdf,
                          size: 12,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Checkbox
              if (onCompletionToggled != null)
                Checkbox(
                  value: isCompleted,
                  onChanged: (value) =>
                      onCompletionToggled!(value ?? false),
                  activeColor: const Color(0xFF25A0DC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
