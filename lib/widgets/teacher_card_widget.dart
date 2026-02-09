import 'package:flutter/material.dart';
import '../models/teacher_model.dart';

class TeacherCardWidget extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherCardWidget({
    Key? key,
    required this.teacher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          // Profile Header
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              image: DecorationImage(
                image: NetworkImage(teacher.profileImage),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
          // Teacher Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacher.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142132),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacher.specialization,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF25A0DC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  teacher.bio,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Contact Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Email
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: Color(0xFF25A0DC),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              teacher.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Phone
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 14,
                          color: Color(0xFF25A0DC),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          teacher.phoneNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
    );
  }
}
