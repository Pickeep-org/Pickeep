import 'package:firebase_auth/firebase_auth.dart';
import 'abstract_firebase_authentication.dart';

class FirebaseEmailAuthentication extends AFirebaseAuthentication {
  String? _email;
  String? _password;
  bool? _isRegisteredUser;

  FirebaseEmailAuthentication.instance() :
        super.instance();

  void initInstance({required String email, required String password, bool isRegisteredUser = true}) {
    _email = email;
    _password = password;
    _isRegisteredUser = isRegisteredUser;
  }

  @override
  Future<UserCredential> signIn() async {

    // TODO:
    if (_email == null || _password == null || _isRegisteredUser == null) {
      throw "TODO: message";
    } else {
      if (!_isRegisteredUser!) {
          final newUser =  await firebaseAuth.createUserWithEmailAndPassword(email: _email!, password: _password!);
          await newUser.user!.sendEmailVerification();
          return newUser;
      }
    return await firebaseAuth.signInWithEmailAndPassword(email: _email!, password: _password!);
    }
  }
}
