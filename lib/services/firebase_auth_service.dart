import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      print('📝 Step 1: Creating Firebase Auth user for $email');

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      print('✅ Step 2: Auth user created: $uid');

      print('📝 Step 3: Saving user to Firestore');

      await _firestore.collection('users').doc(uid).set({
        'id': uid,
        'name': name,
        'email': email,
        'role': role,
      });

      print('✅ Step 4: User saved to Firestore');

      return UserModel(
        id: uid,
        name: name,
        email: email,
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception('Sign up failed: ${e.message}');
    } on FirebaseException catch (e) {
      print('❌ Firestore Error: ${e.code} - ${e.message}');
      throw Exception('Failed to save user data: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📝 Login attempt: $email');

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Login successful');
    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('Email not found. Please sign up first.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password. Please try again.');
      }
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      print('❌ Login exception: $e');
      throw Exception('Login error: $e');
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel(
          id: user.uid,
          name: data['name'] ?? 'User',
          email: user.email ?? '',
          role: data['role'] ?? 'student',
        );
      }

      return UserModel(
        id: user.uid,
        name: 'User',
        email: user.email ?? '',
        role: 'student',
      );
    } catch (e) {
      return null;
    }
  }

  User? getCurrentUser() => _auth.currentUser;

  Future<void> logout() async {
    await _auth.signOut();
  }

  bool isUserLoggedIn() => _auth.currentUser != null;
}
