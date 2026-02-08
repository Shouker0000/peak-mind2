class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String coursesCollection = 'courses';
  static const String enrollmentsCollection = 'enrollments';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';

  // App Info
  static const String appName = 'Peak Mind';
  static const String appTagline = 'Learn Smarter. Go Higher.';

  // Validation
  static const int minPasswordLength = 6;
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
}
