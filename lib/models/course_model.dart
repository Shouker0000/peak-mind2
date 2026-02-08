import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String instructorId;
  final String thumbnailUrl;
  final String videoUrl; // YouTube URL or Video ID
  final double rating;
  final int totalStudents;
  final DateTime createdAt;
  final String category;
  final int duration; // in minutes

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.instructorId,
    this.thumbnailUrl = '',
    required this.videoUrl,
    this.rating = 0.0,
    this.totalStudents = 0,
    required this.createdAt,
    this.category = '',
    this.duration = 0,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor': instructor,
      'instructorId': instructorId,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'rating': rating,
      'totalStudents': totalStudents,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
      'duration': duration,
    };
  }

  // Create from Firestore document
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'] ?? '',
      instructorId: json['instructorId'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalStudents: json['totalStudents'] ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      category: json['category'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }

  // Copy with method for updates
  CourseModel copyWith({
    String? id,
    String? title,
    String? description,
    String? instructor,
    String? instructorId,
    String? thumbnailUrl,
    String? videoUrl,
    double? rating,
    int? totalStudents,
    DateTime? createdAt,
    String? category,
    int? duration,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructor: instructor ?? this.instructor,
      instructorId: instructorId ?? this.instructorId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      rating: rating ?? this.rating,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      duration: duration ?? this.duration,
    );
  }
}
