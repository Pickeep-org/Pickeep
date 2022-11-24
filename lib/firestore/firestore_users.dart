import 'package:cloud_firestore/cloud_firestore.dart';

// Handles the communication with the Users collection in Firestore database using
// noSql queries.
// 1. setUserInfo() - given user id and user information as Json, adds a new
// user document to firestore with empty favorites list.
// 2. tryGetUserInfo() - given user id, gets the user information from the relevant
// document in firestore.
// 3. getUserFavorites() - given user id, gets the user favorites items list from
// the relevant document in firestore.
// 4. addNewFavorite() - given user id and item id, update the favorites list of
// the user with the new item id.
// 5. removeItemFromFavorite() - given user id and item id, remove the item
// id from the favorites list of the user.
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
