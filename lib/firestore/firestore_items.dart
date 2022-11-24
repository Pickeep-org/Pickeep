import 'package:cloud_firestore/cloud_firestore.dart';

// Handles the communication with the Items collection in Firestore database using
// noSql queries. Class main methods:
// 1. addNewItem() - given user id, item (2.1), adds a new item document to
// firestore with its upload time.
// 2. updateItem() - given item id and updated item (2.1), updates the item in
// firestore.
// 3. removeItem() - given item id, removes it from firestore.
// 4. updateImageUrl() - given item id and image url, updates it on firestore.
// 5. getItemsOrderByUploadTime() - returns batch of items ordered by upload
// time.
// 6. getItemsByUser() - given user id, returns batch of items uploaded by the
// user.
class FirestoreItems {
  final CollectionReference _items;

  FirestoreItems.instance()
      : _items = FirebaseFirestore.instance.collection('Items');

  Future<String> addNewItem(String ownerUserUid, Map newItem) async {
    var doc = await _items
        .add({'uid': ownerUserUid, 'item': newItem, 'uploadTime': "null"});
    return doc.id;
  }

  Future updateItem(String itemId, Map updatedItem) async {
    await _items.doc(itemId).update({"item": updatedItem});
  }

  Future removeItem(String itemToRemoveUid) async {
    await _items.doc(itemToRemoveUid).delete();
  }

  Future updateImageUrl(String itemId, String url) async {
    await _items.doc(itemId).update({"item.image": url});
  }

  Future setUploadTime(String itemId) async {
    await _items.doc(itemId).update({"uploadTime": FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot> getItemsOrderByUploadTime() {
    return _items
        .where('uploadTime', isNotEqualTo: "null")
        .orderBy('uploadTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getItemsByUser(String uid) {
    return _items
        .where("uid", isEqualTo: uid)
        .orderBy('uploadTime', descending: true)
        .snapshots();
  }
}
