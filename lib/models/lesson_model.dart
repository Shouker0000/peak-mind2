class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final int lessonNumber;
  final String videoUrl; // YouTube video ID
  final String pdfUrl; // PDF file URL
  final int durationMinutes;
  final DateTime createdAt;
  final bool isLocked; // Premium content or not

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.lessonNumber,
    required this.videoUrl,
    required this.pdfUrl,
    this.durationMinutes = 0,
    required this.createdAt,
    this.isLocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'lessonNumber': lessonNumber,
      'videoUrl': videoUrl,
      'pdfUrl': pdfUrl,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'isLocked': isLocked,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] ?? '',
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      lessonNumber: map['lessonNumber'] ?? 0,
      videoUrl: map['videoUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isLocked: map['isLocked'] ?? false,
    );
  }
}
