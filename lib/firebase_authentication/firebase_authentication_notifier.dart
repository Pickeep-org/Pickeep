import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'abstract_firebase_authentication.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class FirebaseAuthenticationNotifier with ChangeNotifier {

  AFirebaseAuthentication? _instance = null;
  Status _status = Status.Unauthenticated;

  void setFirebaseAuthentication(AFirebaseAuthentication instance) {
    _instance = instance;
    _instance!.firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }


  Future signIn() async {
    _status = Status.Authenticating;
    notifyListeners();
    await _instance!.signIn();
  }

  Future signOut() async {
    await _instance!.signOut();
  }

  Future _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = Status.Unauthenticated;
    } else {
      _status = Status.Authenticated;
    }

    notifyListeners();
  }
}
