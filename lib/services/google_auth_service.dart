import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? '905297662812-bol7ni7n2qns4p1p1gapohd75e13tt1i.apps.googleusercontent.com'
            : null,
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.currentUser != null;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
      }

      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Google Sign-In failed: Missing authentication tokens');
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      print('Google Sign-In successful: ${userCredential.user?.email}');

      try {
        if (userCredential.user?.email != null &&
            userCredential.user!.email!.isNotEmpty) {
          final localStorage = LocalStorageService();
          await localStorage.saveUserInfo(userCredential.user!.email!);
          print('Saved user info: ${userCredential.user!.email!}');
        }
      } catch (e) {
        print('Error saving user info after Google sign-in: $e');
      }
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');

      if (e.toString().contains('popup_closed')) {
        print('Please allow popups for this site and try again');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
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
      };
    }
    return {};
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isGoogleSignedIn() async {
    try {
      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signInSilently();
      return googleUser != null;
    } catch (e) {
      print('Error checking Google sign-in status: $e');
      return false;
    }
  }

  Future<GoogleSignInAccount?> getGoogleUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('Error getting Google user: $e');
      return null;
    }
  }
}
