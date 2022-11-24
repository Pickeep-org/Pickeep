import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../sign_screens/sign_with_phone_screen.dart';
import 'abstract_firebase_authentication.dart';

enum AuthStatus {
  successful,
  invalidPhone,
  unknown,
}
class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-phone-number":
        status = AuthStatus.invalidPhone;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }
  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidPhone:
        errorMessage = "Invalid phone number.";
        break;
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
}

// Class that inherits from AFirebaseAuthentication that handles the authentication
// by phone of a user with firebase.
// Class fields:
// 1. String phone
// 2. UserCredential credential - the UserCredential that’s returned from authentication
// request.
// 3. String email
// 4. String password
// 5. AuthStatus status - enum that holds the authentication responses
class FirebasePhoneAuthentication extends AFirebaseAuthentication {
  late BuildContext _context;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _phone;
  late Future<UserCredential> _credential;

  void initInstance({required String phone, required BuildContext context}) {
    _phone = phone;
    _context = context;

  }

  FirebasePhoneAuthentication.instance() :
        super.instance();

  @override
  Future signIn() async {
    if(await verifyPhone()){
      return _credential;
    }
  }

  // handles the verification of a phone number.
  Future<bool> verifyPhone() async{
    var completer = Completer<bool>();
    await _auth.verifyPhoneNumber(
      phoneNumber: _phone,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          ScaffoldMessenger.of(_context).showSnackBar(
              const SnackBar(content: Text("invalid phone number")));
        } else {
          ScaffoldMessenger.of(_context).showSnackBar(
              const SnackBar(content: Text("Verification failed, please try again later")));
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        await SignWithPhoneScreen().showAlertDialog(_context, (String smsCode){
          PhoneAuthCredential cred = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
          _credential = _auth.signInWithCredential(cred);
          completer.complete(true);
        });},
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return completer.future;
  }

}
