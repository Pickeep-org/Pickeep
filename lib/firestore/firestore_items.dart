import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreItems {
  final CollectionReference _items;

  FirestoreItems.instance()
      : _items = FirebaseFirestore.instance.collection('Items');

  Future<String> addNewItem(String ownerUserUid, Map newItem) async {
    var doc = await _items.add({'uid' : ownerUserUid, 'item': newItem});
    return doc.id;
  }

  Future updateItem(String itemId, Map updatedItem) async{
    await _items.doc(itemId).update({"item": updatedItem});
  }

  Future removeItem(String itemToRemoveUid) async {
    await _items.doc(itemToRemoveUid).delete();
  }
  Future updateImageUrl(String itemId, String url) async{
    await _items.doc(itemId).update({"item.image": url});
  }
  Stream<QuerySnapshot> getItemsOrderByName(List categories) {
    if(categories.isEmpty){
      return _items
          .orderBy('item.name')
          .snapshots();
    }
    return _items
        .where('item.categories', arrayContainsAny: categories)
        .orderBy('item.name')
        .snapshots();
  }
  Stream<QuerySnapshot> getItemsByUser(String uid){
    return _items
        .where("uid", isEqualTo: uid)
        .snapshots();
  }
  
  Stream<QuerySnapshot> getItemsByIdsList(List<String> ids){
    return _items.where(FieldPath.documentId, whereIn: ids).snapshots();

  }

}
