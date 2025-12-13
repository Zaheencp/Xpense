import 'package:firebase_auth/firebase_auth.dart';

class TwoFactorService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<void> sendCode(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Optionally auto-sign in
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<UserCredential> verifyCode(String smsCode) async {
    if (_verificationId == null) throw Exception('No verificationId');
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return await _auth.currentUser!.linkWithCredential(credential);
  }
}
