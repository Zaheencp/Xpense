import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xpense/screens/login.dart';
import 'package:xpense/screens/widgets/bottomnavbar.dart';

class Firebasegoogle {
  //google signin
  Future<UserCredential> signinwithgoogle(BuildContext context) async {
    // Use the singleton instance and authenticate
    final GoogleSignInAccount guser =
        await GoogleSignIn.instance.authenticate();
    // Get tokens for Firebase Auth
    final GoogleSignInAuthentication gauth = guser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: gauth.idToken,
    );
    UserCredential gcredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const Bottom()));
    return gcredential;
  }

  Future<void> signoutgoogle(BuildContext context) async {
    try {
      await GoogleSignIn.instance.disconnect();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => Loginpage()));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
