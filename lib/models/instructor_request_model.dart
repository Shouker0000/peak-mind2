class InstructorRequest {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String grade;
  final String? profilePhotoUrl;
  final String? bio;
  final String status; // pending, approved, rejected
  final DateTime requestDate;
  final DateTime? reviewDate;
  final String? reviewedBy; // admin uid
  final String? rejectionReason;

  InstructorRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.grade,
    this.profilePhotoUrl,
    this.bio,
    required this.status,
    required this.requestDate,
    this.reviewDate,
    this.reviewedBy,
    this.rejectionReason,
  });

  bool isPending() => status == 'pending';
  bool isApproved() => status == 'approved';
  bool isRejected() => status == 'rejected';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'grade': grade,
      'profilePhotoUrl': profilePhotoUrl,
      'bio': bio,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'rejectionReason': rejectionReason,
    };
  }

  factory InstructorRequest.fromMap(Map<String, dynamic> map, String docId) {
    return InstructorRequest(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      subject: map['subject'] ?? '',
      grade: map['grade'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
      bio: map['bio'],
      status: map['status'] ?? 'pending',
      requestDate: DateTime.parse(
          map['requestDate'] ?? DateTime.now().toIso8601String()),
      reviewDate:
          map['reviewDate'] != null ? DateTime.parse(map['reviewDate']) : null,
      reviewedBy: map['reviewedBy'],
      rejectionReason: map['rejectionReason'],
    );
  }
}
