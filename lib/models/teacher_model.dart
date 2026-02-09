class TeacherModel {
  final String id; // Type: String
  final String name; // Type: String
  final String email; // Type: String
  final String profileImage; // Type: String
  final String bio; // Type: String
  final String specialization; // Type: String
  final List<String> subjectIds; // Type: List<String>
  final String phoneNumber; // Type: String

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.bio,
    required this.specialization,
    required this.subjectIds,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'specialization': specialization,
      'subjectIds': subjectIds,
      'phoneNumber': phoneNumber,
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      bio: map['bio'] ?? '',
      specialization: map['specialization'] ?? '',
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
