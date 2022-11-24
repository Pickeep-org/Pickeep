import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_email_authentication.dart';
import 'firebase_google_authentication.dart';
import 'firebase_phone_authentication.dart';

// AFirebaseAuthentication
// Abstract class that handles all of the authentication methods.
// Class fields: FirebaseAuth auth - an instance of firebaseAuth class that handles
// the communication with firebase authentication service. Since the connection
// method differs between the users and may change for each user, we need to treat
// them the same way Class main methods:
// 1. signIn() - handles the sign in of a new/existing user.
// 2. signOut() - handles the sign out of a user.
abstract class AFirebaseAuthentication {
  @protected
  final FirebaseAuth _firebaseAuth;

  FirebaseAuth get firebaseAuth => _firebaseAuth;

  factory AFirebaseAuthentication.fromProviderId(String providerId) {
    late AFirebaseAuthentication firebaseAuthentication;

    if (providerId == 'google.com') {
      firebaseAuthentication = FirebaseGoogleAuthentication.instance();
    } else if (providerId == 'password') {
      firebaseAuthentication = FirebaseEmailAuthentication.instance();
    } else if (providerId == 'phone') {
      firebaseAuthentication = FirebasePhoneAuthentication.instance();
    }

    return firebaseAuthentication;
  }

  @protected
  AFirebaseAuthentication.instance() : _firebaseAuth = FirebaseAuth.instance;

  Future signIn();

  Future signOut() async {
    await _firebaseAuth.signOut();
  }
}
