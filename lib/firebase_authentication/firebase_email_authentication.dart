import 'package:firebase_auth/firebase_auth.dart';
import 'abstract_firebase_authentication.dart';

enum AuthStatus {
  successful,
  invalidEmail,
  unknown,
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }
  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = "Invalid email address.";
        break;
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
}

// Class that inherits from AFirebaseAuthentication that handles the authentication
// by email of a user with firebase.
// Class fields:
// 1. String email
// 2. String password
// 3. AuthStatus status - enum that holds the authentication responses
// Class main methods:
// 1. resetPassword() - handles a reset password request of a user.
class FirebaseEmailAuthentication extends AFirebaseAuthentication {
  String? _email;
  String? _password;
  bool? _isRegisteredUser;
  final _auth = FirebaseAuth.instance;
  late AuthStatus _status;

  FirebaseEmailAuthentication.instance() :
        super.instance();

  void initInstance({required String email, required String password, bool isRegisteredUser = true}) {
    _email = email;
    _password = password;
    _isRegisteredUser = isRegisteredUser;
  }

  @override
  Future signIn() async {
      if (!_isRegisteredUser!) {
          final newUser =  await firebaseAuth.createUserWithEmailAndPassword(email: _email!, password: _password!);
          final user = newUser.user;
          if(user != null){
            await user.sendEmailVerification();
          }
      }
    await firebaseAuth.signInWithEmailAndPassword(email: _email!, password: _password!);
  }
  Future<AuthStatus> resetPassword({required String email}) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError((e) => _status = AuthExceptionHandler.handleAuthException(e));
    return _status;
  }
}
