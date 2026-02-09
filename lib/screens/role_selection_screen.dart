import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up with email and password
  Future<User?> signup(
    String email,
    String password, {
    String? name,
    String? role,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null && name != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'The account already exists for that email.';
      } else {
        throw e.message ?? 'An error occurred';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Login with email and password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else {
        throw e.message ?? 'An error occurred';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw e.toString();
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }
}
