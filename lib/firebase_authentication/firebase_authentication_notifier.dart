import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'abstract_firebase_authentication.dart';

enum Status { uninitialized, authenticated, authenticating, unauthenticated }

// This class is being used for alerting when there is a disconnection/connection so
// a loading circle will be shown until the connection is established and only then
// the user is being navigated to the home screen.
// Class main methods:
// 1. signIn() - handles the sign in of a new/existing user.
// 2. signOut() - handles the sign out of a user.
class FirebaseAuthenticationNotifier with ChangeNotifier {
  AFirebaseAuthentication? _instance;
  Status _status = Status.unauthenticated;

  void setFirebaseAuthentication(AFirebaseAuthentication instance) {
    _instance = instance;
    _instance!.firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future signIn() async {
    _status = Status.authenticating;
    notifyListeners();
    await _instance!.signIn();
  }

  Future signOut() async {
    await _instance!.signOut();
  }

  Future _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.unauthenticated;
    } else {
      _status = Status.authenticated;
    }

    notifyListeners();
  }
}
