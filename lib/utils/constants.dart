class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String enrollmentsCollection = 'enrollments';
  static const String instructorRequestsCollection = 'instructor_requests';
  static const String activityLogsCollection = 'activity_logs';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleInstructor = 'instructor';
  static const String roleAdmin = 'admin';

  // Instructor Status
  static const String instructorStatusPending = 'pending';
  static const String instructorStatusApproved = 'approved';
  static const String instructorStatusRejected = 'rejected';

  // Permissions
  static const String permCanCreateCourse = 'can_create_course';
  static const String permCanEditCourse = 'can_edit_course';
  static const String permCanDeleteCourse = 'can_delete_course';
  static const String permCanViewAnalytics = 'can_view_analytics';
  static const String permCanManageUsers = 'can_manage_users';
  static const String permCanSuspendUsers = 'can_suspend_users';
  static const String permCanReviewInstructors = 'can_review_instructors';

  // App Info
  static const String appName = 'Peak Mind';
  static const String appTagline = 'Learn Smarter. Go Higher.';

  // Validation
  static const int minPasswordLength = 6;
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
}
