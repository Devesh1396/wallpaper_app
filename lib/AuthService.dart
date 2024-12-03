import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
/*class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the Google Sign-In authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential for Firebase authentication
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Return the authenticated user
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Fetch user details
  User? getCurrentUser() {
    return _auth.currentUser; // Returns the currently authenticated user
  }

  // Fetch additional user details
  Map<String, String?> fetchUserDetails() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return {
        "displayName": null,
        "email": null,
        "photoURL": null,
        "uid": null,
      };
    }

    return {
      "displayName": user.displayName,
      "email": user.email,
      "photoURL": user.photoURL,
      "uid": user.uid,
    };
  }

}*/

class AutheProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  AutheProvider() {
    _listenToAuthChanges();
  }

  User? get currentUser => _currentUser;

  String get displayName => _currentUser?.displayName ?? "Guest";
  String get photoURL =>
      _currentUser?.photoURL ?? "assets/images/user_profile.png";

  bool get isLoggedIn => _currentUser != null;

  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Fetch the currently signed-in user's email
  String? getCurrentUserEmail() {
    return _currentUser?.email;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();

      await googleSignIn.signOut();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) return; // User canceled sign-in

      // Show modal sheet while signing in
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                // Text
                const Text(
                  'Signing you in...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                // Loader
                const CircularProgressIndicator(),
              ],
            ),
          );
        },
      );

      // Authenticate with Firebase
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      // Once signed in, dismiss the modal
      Navigator.pop(context);
    } catch (e) {
      // Dismiss the modal in case of error
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Sign-in failed. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      debugPrint("Error signing in: $e");
      throw Exception("Failed to sign in");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

