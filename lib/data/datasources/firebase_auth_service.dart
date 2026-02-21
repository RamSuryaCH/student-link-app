import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<firebase_auth.User?> get userChanges => _firebaseAuth.authStateChanges();

  // Current authenticated user (synchronous)
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<UserEntity?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      if (credential.user != null) {
        // Fetch custom user profile from Firestore
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (doc.exists) {
          return UserEntity.fromMap(doc.data()!);
        }
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during sign in');
    }
  }

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String department,
    String role = 'Student',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      final newUser = UserEntity(
        id: credential.user!.uid,
        name: name,
        email: email,
        department: department,
        role: role,
        createdAt: DateTime.now(),
      );

      // Save user to Firestore profile
      await _firestore.collection('users').doc(newUser.id).set(newUser.toMap());

      return newUser;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Signup failed');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
