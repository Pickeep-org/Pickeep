
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_email_authentication.dart';
import 'firebase_google_authentication.dart';

abstract class AFirebaseAuthentication {

  @protected
  final FirebaseAuth _firebaseAuth;

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  factory AFirebaseAuthentication.fromProviderId(String providerId) {
    late AFirebaseAuthentication firebaseAuthentication;

    if(providerId == 'google.com') {
      firebaseAuthentication = FirebaseGoogleAuthentication.instance();
    } else if (providerId == 'password'){
      firebaseAuthentication = FirebaseEmailAuthentication.instance();
    }

    return firebaseAuthentication;
  }

  @protected
  AFirebaseAuthentication.instance() :
        _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signIn();

  Future signOut() async {
    await _firebaseAuth.signOut();
  }
}