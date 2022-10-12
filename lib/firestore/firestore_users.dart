import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {

  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  Future setUserInfo(String userUid, Map<String, dynamic> userInfo) async {
    List<String> fav = [];
    await _users.doc(userUid).set({'UserInfo' : userInfo, 'FavoritesItems': fav});
  }

  Future<Map<String, dynamic>> tryGetUserInfo(String userUid) async {
    return (await _users.doc(userUid).get()).get('UserInfo');
  }

  Future<List<String>> getUserFavorites(String uid) async {
    var data  = await _users.doc(uid).get();
    if (data['FavoritesItems'] == null){
      return [];
    }
    return List.from(data['FavoritesItems']);
  }

  Future addNewFavorite(String uid, String itemID) async{
    _users.doc(uid).update({"FavoritesItems": FieldValue.arrayUnion([itemID])});
  }

  Future removeItemFromFavorite(String uid, String itemID) async{
    _users.doc(uid).update({"FavoritesItems": FieldValue.arrayRemove([itemID])});
  }

}
