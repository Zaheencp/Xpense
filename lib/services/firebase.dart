import 'package:firebase_auth/firebase_auth.dart';

class FireBaseFunction {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // UserCredential userCredential=loginuser(email: email, password: password)
  Future<String?> registeruser(
      {required String email, required String password}) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      print(e);

      return e.message;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<String?> loginuser(
      {required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }
}
