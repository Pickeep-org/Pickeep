
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {

  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  Future setUserInfo(String userUid, Map<String, dynamic> userInfo) async {
    await _users.doc(userUid).set({'UserInfo' : userInfo});
  }

  Future<Map<String, dynamic>> tryGetUserInfo(String userUid) async {
    return (await _users.doc(userUid).get()).get('UserInfo');
  }
}
