import 'package:firebase_auth/firebase_auth.dart';
import 'firestore/firestore_users.dart';

// Static class that holds the favorite items of the logged in user.
// Class fields: List favorites Class main methods:
// 1. add()
// 2. remove()
// 3. contains() - returns if an item is a favorite.
// 4. getFromDB() - extracts the favorites of the user from firestore.
// 5. addFavoriteToDB() - adds an item to the user’s favorites on firestore.
// 6. removeFavoriteFromDB() - removes an item from the user’s favorites on
// firestore.
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