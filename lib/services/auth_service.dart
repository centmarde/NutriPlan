import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Constructor to initialize locale
  AuthService() {
    // Set Firebase Auth language to device locale
    final String languageCode = ui.window.locale.languageCode;
    _auth.setLanguageCode(languageCode);
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Set Firebase Auth language to device locale
      final String languageCode = ui.window.locale.languageCode;
      if (languageCode.isNotEmpty) {
        _auth.setLanguageCode(languageCode);
      } else {
        print('Warning: Empty language code detected');
      }

      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code}, ${e.message}');
      rethrow;
    } catch (e) {
      if (e.toString().contains('X-Firebase-Locale')) {
        print('Firebase Locale Error: ${e.toString()}');
        throw Exception(
          'Firebase locale error: Please check your device language settings',
        );
      }
      print('Login Error: ${e.toString()}');
      rethrow;
    }
  }

  // Register with email and password (with reCAPTCHA verification)
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Configure reCAPTCHA for web platforms
      if (kIsWeb) {
        // Web-specific reCAPTCHA verification would go here
        // This is a simplified example
      }

      // Set the auth language code to prevent locale warnings
      final String languageCode = ui.window.locale.languageCode;
      _auth.setLanguageCode(languageCode);

      // Create the user in Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Specific handling for Firebase auth exceptions
      print('Firebase Auth Error: ${e.code}, ${e.message}');
      rethrow;
    } catch (e) {
      print('Registration Error: ${e.toString()}');
      rethrow;
    }
  }

  // Create user profile in Firestore (without requiring full name)
  Future<void> createUserProfile(String userId, [String? fullName]) async {
    try {
      // Store user data in Firestore
      await _firestore.collection('users').doc(userId).set({
        'fullName': fullName ?? '', // Use empty string if no name provided
        'email': _auth.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
        // Add any default fields your app needs
        'preferences': {},
        'settings': {'notifications': true},
      });
    } catch (e) {
      print(
        'ERROR: Failed to create user profile for userId: $userId - ${e.toString()}',
      );
      rethrow;
    }
  }

  // Combined registration function (now without requiring fullName)
  Future<UserCredential> registerUser(
    String email,
    String password, [
    String? fullName,
  ]) async {
    try {
      // Step 1: Create auth user
      final userCredential = await registerWithEmailAndPassword(
        email,
        password,
      );

      // Step 2: Create user profile in Firestore with or without name
      await createUserProfile(userCredential.user!.uid, fullName);

      // Wait a moment to ensure Firestore data is available
      await Future.delayed(const Duration(milliseconds: 500));

      // Return the user credential
      return userCredential;
    } catch (e) {
      print('Registration Error: ${e.toString()}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('ERROR: Failed to sign out user - ${e.toString()}');
      rethrow;
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserDetailsForPigeon() async {
    try {
      if (currentUser == null) return null;

      final userData = await getUserData();
      if (userData == null) return null;

      // Return properly formatted user details for Pigeon
      return {
        'userId': currentUser?.uid,
        'fullName': userData['fullName'],
        'email': userData['email'],
        // Add other fields as needed
      };
    } catch (e) {
      print('Error getting user details for Pigeon: ${e.toString()}');
      return null; // Return null on error instead of rethrowing
    }
  }
}
