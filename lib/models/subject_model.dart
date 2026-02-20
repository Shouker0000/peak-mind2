class SubjectModel {
  final String id;
  final String title;
  final List<String> applicableStages;
  final List<String> applicableGrades;
  final String? imageUrl; // Add this field

  SubjectModel({
    required this.id,
    required this.title,
    required this.applicableStages,
    required this.applicableGrades,
    this.imageUrl, // Add this
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      applicableStages: List<String>.from(map['applicableStages'] ?? []),
      applicableGrades: List<String>.from(map['applicableGrades'] ?? []),
      imageUrl: map['imageUrl'], // Add this
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'applicableStages': applicableStages,
      'applicableGrades': applicableGrades,
      'imageUrl': imageUrl, // Add this
    };
  }
}
