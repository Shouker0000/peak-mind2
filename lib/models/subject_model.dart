class SubjectModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int numberOfTeachers;
  final List<String> applicableStages; // ['prepatory', 'secondary', 'college']
  final List<String> applicableGrades; // ['One', 'Two', 'Three', etc]
  final int courseCount;

  SubjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.numberOfTeachers,
    required this.applicableStages,
    required this.applicableGrades,
    required this.courseCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'numberOfTeachers': numberOfTeachers,
      'applicableStages': applicableStages,
      'applicableGrades': applicableGrades,
      'courseCount': courseCount,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      numberOfTeachers: map['numberOfTeachers'] ?? 0,
      applicableStages: List<String>.from(map['applicableStages'] ?? []),
      applicableGrades: List<String>.from(map['applicableGrades'] ?? []),
      courseCount: map['courseCount'] ?? 0,
    );
  }
}
