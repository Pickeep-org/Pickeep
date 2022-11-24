import 'contact_Info.dart';
import 'firestore/firestore_users.dart';

// Static class that holds the contact info of the current logged in user.
// Class fields:
// 1. ContactInfo user - An instance of ContactInfo (2.2).
// Class main methods:
// 1. updateUser() - updating user information if edited from the app.
// 2. loadUser() - given user id, extracting the contact information of the user
// from firestore.
class CurrentUserInfo {
  static final CurrentUserInfo _instance = CurrentUserInfo._intInstance();
  late ContactInfo user;
  late String uid;

  factory CurrentUserInfo() {
    return _instance;
  }
  CurrentUserInfo._intInstance();
  updateUser(ContactInfo contactInfo) {
    user = contactInfo;
  }

  Future loadUser(String uid) async {
    user = ContactInfo.fromJason(await FirestoreUser().tryGetUserInfo(uid));
  }
}
