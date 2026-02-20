class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String profileImage;
  final String bio;
  final String specialization;
  final List<String> subjectIds;
  final String phoneNumber;

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
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      profileImage: map['profileImage']?.toString() ?? '',
      bio: map['bio']?.toString() ?? '',
      specialization: map['specialization']?.toString() ?? '',
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
      phoneNumber: map['phoneNumber']?.toString() ?? '',
    );
  }
}
