import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final displayName = email.split('@')[0];
      await userCredential.user?.updateDisplayName(displayName);

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = 'An error occurred during sign up: ${e.message}';
      }
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = 'An error occurred during sign in: ${e.message}';
      }
      return AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      print(
        'FirebaseAuthService: Attempting to send password reset email to $email',
      );

      await _auth.sendPasswordResetEmail(email: email.trim());

      print('FirebaseAuthService: Password reset email sent successfully');
      return AuthResult.success(
        null,
        message: 'Password reset email sent successfully',
      );
    } on FirebaseAuthException catch (e) {
      print(
        'FirebaseAuthService: FirebaseAuthException - ${e.code}: ${e.message}',
      );
      String message;
      switch (e.code) {
        case 'user-not-found':
          message =
              'No user found with that email address. Please check the email or create a new account.';
          break;
        case 'invalid-email':
          message =
              'The email address is not valid. Please enter a correct email address.';
          break;
        case 'too-many-requests':
          message =
              'Too many attempts. Please wait a few minutes before trying again.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection and try again.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled. Please contact support.';
          break;
        case 'operation-not-allowed':
          message =
              'Password reset is not enabled for this app. Please contact support.';
          break;
        default:
          message =
              'An error occurred: ${e.message ?? 'Unknown error'} (Code: ${e.code})';
      }
      return AuthResult.failure(message);
    } catch (e) {
      print('FirebaseAuthService: Unexpected error - $e');
      return AuthResult.failure('An unexpected error occurred: $e');
    }
  }

  Future<AuthResult> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        return AuthResult.success(user);
      }
      return AuthResult.failure('No user is currently signed in');
    } catch (e) {
      return AuthResult.failure('Failed to update profile: $e');
    }
  }

  Future<AuthResult> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        return AuthResult.success(
          null,
          message: 'Account deleted successfully',
        );
      }
      return AuthResult.failure('No user is currently signed in');
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }

  Map<String, String> getUserProfile() {
    final user = _auth.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'emailVerified': user.emailVerified.toString(),
        'creationTime': user.metadata.creationTime?.toIso8601String() ?? '',
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String() ?? '',
      };
    }
    return {};
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String message;

  AuthResult.success(
    this.user, {
    this.message = 'Operation completed successfully',
  }) : isSuccess = true;

  AuthResult.failure(this.message) : isSuccess = false, user = null;
}
