import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'abstract_firebase_authentication.dart';

// Class that inherits from AFirebaseAuthentication that handles authentication
// using Google authentication services.
// Class fields: GoogleSignIn googleUser - an instance of GoogleSignIn that handles
// the communication with Google Authentication service.
class FirebaseGoogleAuthentication extends AFirebaseAuthentication {
  final GoogleSignIn _googleUser;

  FirebaseGoogleAuthentication.instance() :
        _googleUser = GoogleSignIn(), super.instance();

  @override
  Future signIn() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleUser.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future signOut() async {
    await _googleUser.signOut();
    await super.signOut();
  }
}
