import 'contact_Info.dart';
import 'firestore/firestore_users.dart';

class CurrentUserInfo {
  static final CurrentUserInfo _instance = CurrentUserInfo._intInstance();
  late ContactInfo user;
  late String uid;

  factory CurrentUserInfo() {
    return _instance;
  }
  CurrentUserInfo._intInstance();
  updateUser(ContactInfo contactInfo){
    user = contactInfo;
  }

  Future loadUser(String uid) async {
    user = ContactInfo.fromJason(await FirestoreUser().tryGetUserInfo(uid));
  }
}
