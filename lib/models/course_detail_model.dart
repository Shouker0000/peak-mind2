import 'teacher_model.dart';
import 'lesson_model.dart';

class CourseDetailModel {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final TeacherModel teacher;
  final List<LessonModel> lessons;
  final double rating;
  final int enrolledStudents;
  final String coverImage;
  final DateTime createdAt;

  CourseDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.teacher,
    required this.lessons,
    this.rating = 0.0,
    this.enrolledStudents = 0,
    required this.coverImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'teacherId': teacher.id,
      'rating': rating,
      'enrolledStudents': enrolledStudents,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CourseDetailModel.fromMap(
    Map<String, dynamic> map,
    TeacherModel teacher,
    List<LessonModel> lessons,
  ) {
    return CourseDetailModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subjectId: map['subjectId'] ?? '',
      teacher: teacher,
      lessons: lessons,
      rating: (map['rating'] ?? 0.0).toDouble(),
      enrolledStudents: map['enrolledStudents'] ?? 0,
      coverImage: map['coverImage'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
