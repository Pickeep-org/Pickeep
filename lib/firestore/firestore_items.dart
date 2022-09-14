import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreItems {
  final CollectionReference _items;

  FirestoreItems.instance()
      : _items = FirebaseFirestore.instance.collection('Items');

  Future addNewItem(String ownerUserUid, Map newItem) async {
    await _items.add({'owner uid' : ownerUserUid, 'item': newItem});
  }

  Future removeItem(String itemToRemoveUid) async {
    await _items.doc(itemToRemoveUid).delete();
  }

  Stream<QuerySnapshot> getItemsOrderByName({List? categories}) {
    return _items
        .where("item.categories", whereIn: categories)
        .orderBy('item.name')
        .snapshots();
  }
  
  Stream<QuerySnapshot> getItemsByUser(String uid){
    return _items
        .where("uid", isEqualTo: uid)
        .snapshots();
  }
}
