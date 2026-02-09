class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final int birthYear;
  final String stage; // prepatory, secondary, college
  final String grade;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.birthYear,
    required this.stage,
    required this.grade,
    required this.createdAt,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'birthYear': birthYear,
      'stage': stage,
      'grade': grade,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firebase document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthYear: map['birthYear'] ?? 0,
      stage: map['stage'] ?? '',
      grade: map['grade'] ?? '',
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
