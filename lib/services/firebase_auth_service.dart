import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('User created successfully: ${userCredential.user!.uid}');
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed');
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  // Login - FIXED VERSION
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      print('Attempting login with email: $email');

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Login successful: ${userCredential.user?.uid}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');

      // Provide user-friendly error messages
      if (e.code == 'user-not-found') {
        throw Exception('Email not found. Please sign up first.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Invalid email format.');
      } else if (e.code == 'user-disabled') {
        throw Exception('This account has been disabled.');
      } else {
        throw Exception(e.message ?? 'Login failed');
      }
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Login error: $e');
    }
  }

  // Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        print('No current user');
        return null;
      }

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        print('User document not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('User logged out');
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout error: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}
