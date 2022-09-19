

import 'package:firebase_auth/firebase_auth.dart';

import 'firestore/firestore_users.dart';

class Favorites{
  static final Favorites _instance = Favorites._intInstance();
  late List<String> favorites = [];

  factory Favorites() {
    return _instance;
  }
  Favorites._intInstance();

  bool contain(String itemId){
    return favorites.contains(itemId);
  }

  void add(String itemId){
    favorites.add(itemId);
  }
  void remove(String itemId){
    favorites.remove(itemId);
  }
  List<String> get(){
    return favorites;
  }
  Future getFromDB(String uid) async {
    favorites = await FirestoreUser().getUserFavorites(uid);
  }
  Future addFavoriteToDB(String itemId) async {
    await FirestoreUser().addNewFavorite(FirebaseAuth.instance.currentUser!.uid, itemId);
  }

  Future removeFavoriteFromDB(String itemId) async {
    await FirestoreUser().removeItemFromFavorite(FirebaseAuth.instance.currentUser!.uid, itemId);
  }
}