import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yspc/services/firestore_service.dart'; // NEW: Import for FirestoreService

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Email + Password Sign Up
// 1. Email + Password Sign Up
  Future<User?> signUpWithEmail(String email, String password, {String? name}) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      // ← NEW: Always guarantee a display name
      final String displayName = name?.trim().isNotEmpty == true
          ? name!.trim()
          : email.split('@').first.split('.').map((e) => e.capitalize()).join(' ');

      await user.updateDisplayName(displayName);
      await user.reload();

      await FirestoreService().createUserProfile(
        uid: user.uid,
        email: email,
        name: displayName, // ← Save to Firestore too
      );
      await FirestoreService().startFreeTrial(user.uid);
    }
    return user;
  }

  // Email + Password Sign In
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      await _ensureDisplayNameExists(user, email);
    }
    return user;
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        await _ensureDisplayNameExists(
          user,
          user.email ?? '',
        );
      }

      return user;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }
  Future<void> _ensureDisplayNameExists(User user, String email) async {
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      // Name already exists → just make sure Firestore has it
      await FirestoreService().updateUserField(user.uid, 'name', user.displayName!.trim());
      return;
    }

    // No name → create a beautiful one from email
    String newName = email.split('@').first;
    // Convert john.doe@gmail → John Doe
    newName = newName.split('.').map((part) => part.capitalize()).join(' ');

    await user.updateDisplayName(newName);
    await user.reload();
    await FirestoreService().updateUserField(user.uid, 'name', newName);
  }





  Future<void> reauthenticateUser(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  // For Google re-auth (if user signed in with Google)
  Future<void> reauthenticateWithGoogle() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    await _googleSignIn.initialize();

    final GoogleSignInAccount googleUser =
    await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await user.reauthenticateWithCredential(credential);
  }

  // Delete Account (call after re-auth)
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirestoreService().deleteUserData(user.uid); // Delete Firestore data
      await user.delete(); // Delete auth user
    }
  }


  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
  // Current User
  User? get currentUser => _auth.currentUser;

  // Stream of Auth State
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}


extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}