import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final int birthYear;
  final String stage; // prepatory, secondary, college
  final String grade;
  final DateTime createdAt;

  // NEW FIELDS FOR ROLE-BASED SYSTEM
  final String role; // student, instructor, admin
  final bool isActive; // for account suspension
  final Map<String, bool> permissions; // user-specific permissions

  // INSTRUCTOR-SPECIFIC FIELDS
  final String? instructorSubject; // subject they teach
  final String? instructorGrade; // grade they teach
  final String? profilePhotoUrl; // instructor profile picture
  final String? instructorStatus; // pending, approved, rejected
  final DateTime? instructorRequestDate;
  final String? instructorBio; // instructor bio/description

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.birthYear,
    required this.stage,
    required this.grade,
    required this.createdAt,
    this.role = 'student',
    this.isActive = true,
    this.permissions = const {},
    this.instructorSubject,
    this.instructorGrade,
    this.profilePhotoUrl,
    this.instructorStatus,
    this.instructorRequestDate,
    this.instructorBio,
  });

  // Helper methods
  bool isAdmin() => role == 'admin';
  bool isInstructor() => role == 'instructor';
  bool isStudent() => role == 'student';

  bool hasPermission(String permission) {
    return permissions[permission] ?? false;
  }

  bool canBeginApprovedInstructor() =>
      instructorStatus == 'approved' && role == 'instructor';

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
      'role': role,
      'isActive': isActive,
      'permissions': permissions,
      'instructorSubject': instructorSubject,
      'instructorGrade': instructorGrade,
      'profilePhotoUrl': profilePhotoUrl,
      'instructorStatus': instructorStatus,
      'instructorRequestDate': instructorRequestDate?.toIso8601String(),
      'instructorBio': instructorBio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Helper function to safely convert createdAt
    DateTime parseCreatedAt(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      return DateTime.now();
    }

    // Helper function to safely parse int
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Helper function to safely parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      return null;
    }

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthYear: parseInt(map['birthYear']),
      stage: map['stage'] ?? '',
      grade: map['grade'] ?? '',
      createdAt: parseCreatedAt(map['createdAt']),
      role: map['role'] ?? 'student',
      isActive: map['isActive'] ?? true,
      permissions: Map<String, bool>.from(map['permissions'] ?? {}),
      instructorSubject: map['instructorSubject'],
      instructorGrade: map['instructorGrade'],
      profilePhotoUrl: map['profilePhotoUrl'],
      instructorStatus: map['instructorStatus'],
      instructorRequestDate: parseDateTime(map['instructorRequestDate']),
      instructorBio: map['instructorBio'],
    );
  }
}
