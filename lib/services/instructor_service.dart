import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/instructor_request_model.dart';
import '../utils/constants.dart';

class InstructorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit instructor request
  Future<String> submitInstructorRequest({
    required String userId,
    required UserModel user,
    required String subject,
    required String grade,
    String? profilePhotoUrl,
    String? bio,
  }) async {
    try {
      // Check if already has pending request
      final existingRequest = await _firestore
          .collection(AppConstants.instructorRequestsCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: AppConstants.instructorStatusPending)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw 'You already have a pending instructor request. Please wait for admin review.';
      }

      // Create instructor request
      DocumentReference docRef = await _firestore
          .collection(AppConstants.instructorRequestsCollection)
          .add({
        'userId': userId,
        'userName': user.displayName,
        'userEmail': user.email,
        'subject': subject,
        'grade': grade,
        'profilePhotoUrl': profilePhotoUrl,
        'bio': bio,
        'status': AppConstants.instructorStatusPending,
        'requestDate': FieldValue.serverTimestamp(),
        'reviewDate': null,
        'reviewedBy': null,
        'rejectionReason': null,
      });

      // Update user with pending status
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'instructorSubject': subject,
        'instructorGrade': grade,
        'profilePhotoUrl': profilePhotoUrl,
        'instructorBio': bio,
        'instructorStatus': AppConstants.instructorStatusPending,
        'instructorRequestDate': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get instructor request by user ID
  Future<InstructorRequest?> getInstructorRequestByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.instructorRequestsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return InstructorRequest.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>,
            snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all pending instructor requests
  Future<List<InstructorRequest>> getPendingInstructorRequests() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.instructorRequestsCollection)
          .where('status', isEqualTo: AppConstants.instructorStatusPending)
          .orderBy('requestDate', descending: true)
          .get();

      print('Found ${snapshot.docs.length} pending requests'); // Debug

      return snapshot.docs.map((doc) {
        print('Request data: ${doc.data()}'); // Debug
        return InstructorRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting pending requests: $e');
      return [];
    }
  }

  // Approve instructor request
  Future<void> approveInstructorRequest({
    required String requestId,
    required String userId,
    required String adminId,
  }) async {
    try {
      // Update request status
      await _firestore
          .collection(AppConstants.instructorRequestsCollection)
          .doc(requestId)
          .update({
        'status': AppConstants.instructorStatusApproved,
        'reviewDate': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
      });

      // Update user role to instructor
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'role': AppConstants.roleInstructor,
        'instructorStatus': AppConstants.instructorStatusApproved,
      });

      // Log activity
      await _firestore.collection(AppConstants.activityLogsCollection).add({
        'userId': userId,
        'action': 'instructor_approved',
        'details': 'User approved as instructor by admin',
        'metadata': {
          'requestId': requestId,
          'approvedBy': adminId,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Reject instructor request
  Future<void> rejectInstructorRequest({
    required String requestId,
    required String userId,
    required String adminId,
    required String rejectionReason,
  }) async {
    try {
      // Update request status
      await _firestore
          .collection(AppConstants.instructorRequestsCollection)
          .doc(requestId)
          .update({
        'status': AppConstants.instructorStatusRejected,
        'reviewDate': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'rejectionReason': rejectionReason,
      });

      // Update user status
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'instructorStatus': AppConstants.instructorStatusRejected,
      });

      // Log activity
      await _firestore.collection(AppConstants.activityLogsCollection).add({
        'userId': userId,
        'action': 'instructor_rejected',
        'details': 'User instructor request rejected by admin',
        'metadata': {
          'requestId': requestId,
          'rejectedBy': adminId,
          'reason': rejectionReason,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Check instructor status
  Future<String> getInstructorStatus(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc['instructorStatus'] ?? 'none';
      }
      return 'none';
    } catch (e) {
      return 'none';
    }
  }
}
