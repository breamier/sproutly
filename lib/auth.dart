import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Sign in failed: $e');
      throw e;
    }
  }

  Future<void> createUserWithEmailAndPassword(
    String username,
    String email,
    String password,
  ) async {
    try {
      // check if username already exists
      final query =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (query.docs.isNotEmpty) {
        throw Exception('Username already taken');
      }

      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      // Add user to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set({
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'username': username,
          });
    } catch (e) {
      debugPrint('User creation failed: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
      throw e;
    }
  }
}
