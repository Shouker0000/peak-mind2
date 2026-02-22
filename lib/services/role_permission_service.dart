import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class RolePermissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user role
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc['role'] ?? AppConstants.roleStudent;
      }
      return AppConstants.roleStudent;
    } catch (e) {
      return AppConstants.roleStudent;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin(String uid) async {
    final role = await getUserRole(uid);
    return role == AppConstants.roleAdmin;
  }

  // Check if user is instructor
  Future<bool> isInstructor(String uid) async {
    final role = await getUserRole(uid);
    return role == AppConstants.roleInstructor;
  }

  // Check if user is student
  Future<bool> isStudent(String uid) async {
    final role = await getUserRole(uid);
    return role == AppConstants.roleStudent;
  }

  // Check if user is active
  Future<bool> isUserActive(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc['isActive'] ?? true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  // Get user permissions
  Future<Map<String, bool>> getUserPermissions(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        Map<String, bool> perms =
            Map<String, bool>.from(doc['permissions'] ?? {});
        return perms;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Check specific permission
  Future<bool> hasPermission(String uid, String permission) async {
    try {
      final permissions = await getUserPermissions(uid);
      return permissions[permission] ?? false;
    } catch (e) {
      return false;
    }
  }

  // Set user role
  Future<void> setUserRole(String uid, String role) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'role': role});
    } catch (e) {
      rethrow;
    }
  }

  // Set user permissions
  Future<void> setUserPermissions(
      String uid, Map<String, bool> permissions) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'permissions': permissions});
    } catch (e) {
      rethrow;
    }
  }

  // Suspend user
  Future<void> suspendUser(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'isActive': false});

      // Log activity
      await logActivity(
        userId: uid,
        action: 'user_suspended',
        details: 'User account suspended by admin',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Activate user
  Future<void> activateUser(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'isActive': true});

      // Log activity
      await logActivity(
        userId: uid,
        action: 'user_activated',
        details: 'User account activated by admin',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Log activity
  Future<void> logActivity({
    required String userId,
    required String action,
    required String details,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection(AppConstants.activityLogsCollection).add({
        'userId': userId,
        'action': action,
        'details': details,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Get default permissions for role
  static Map<String, bool> getDefaultPermissionsForRole(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return {
          AppConstants.permCanCreateCourse: true,
          AppConstants.permCanEditCourse: true,
          AppConstants.permCanDeleteCourse: true,
          AppConstants.permCanViewAnalytics: true,
          AppConstants.permCanManageUsers: true,
          AppConstants.permCanSuspendUsers: true,
          AppConstants.permCanReviewInstructors: true,
        };
      case AppConstants.roleInstructor:
        return {
          AppConstants.permCanCreateCourse: true,
          AppConstants.permCanEditCourse: true,
          AppConstants.permCanDeleteCourse: false,
          AppConstants.permCanViewAnalytics: true,
          AppConstants.permCanManageUsers: false,
          AppConstants.permCanSuspendUsers: false,
          AppConstants.permCanReviewInstructors: false,
        };
      case AppConstants.roleStudent:
      default:
        return {
          AppConstants.permCanCreateCourse: false,
          AppConstants.permCanEditCourse: false,
          AppConstants.permCanDeleteCourse: false,
          AppConstants.permCanViewAnalytics: false,
          AppConstants.permCanManageUsers: false,
          AppConstants.permCanSuspendUsers: false,
          AppConstants.permCanReviewInstructors: false,
        };
    }
  }
}
