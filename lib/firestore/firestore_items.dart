import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreItems {
  final CollectionReference _items;

  FirestoreItems.instance()
      : _items = FirebaseFirestore.instance.collection('Items');


  Future<String> addNewItem(String ownerUserUid, Map newItem) async {
    var doc = await _items.add({'uid' : ownerUserUid, 'item': newItem, 'uploadTime': FieldValue.serverTimestamp()});
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
  
  Stream<QuerySnapshot> getItemsOrderByName(List cats, List locs, String filterType) {
    if(filterType == 'None'){
      return _items
          .orderBy('uploadTime', descending: true)
          .snapshots();
    }
    if(filterType == 'Both'){
      Stream<QuerySnapshot> s_1 = _items
          .where('item.location', whereIn: locs)
          .where('item.categories', arrayContains: cats[0])
          .orderBy('uploadTime', descending: true)
          .snapshots();
      for(int i = 1; i<cats.length; i++){
        Stream<QuerySnapshot> s_2 = _items
            .where('item.location', whereIn: locs)
            .where('item.categories', arrayContains: cats[i])
            .orderBy('uploadTime', descending: true)
            .snapshots();
        s_1.mergeWith([s_2]);
      }
      return s_1;
    }
    if(filterType == 'Category'){
      return _items
          .where('item.categories', arrayContainsAny: cats)
          .orderBy('uploadTime', descending: true)
          .snapshots();
    }
    else {
      return _items
          .where('item.location', whereIn: locs)
          .orderBy('uploadTime', descending: true)
          .snapshots();
    }

  }
  Stream<QuerySnapshot> getItemsByUser(String uid){
    return _items
        .where("uid", isEqualTo: uid)
        .orderBy('uploadTime', descending: true)
        .snapshots();
  }
  
  Stream<QuerySnapshot> getItemsByIdsList(List<String> ids){
    if (ids.isEmpty){
      return Stream.empty();
    }
    return _items
        .where(FieldPath.documentId, whereIn: ids)
        //.orderBy('uploadTime', descending: true)
        .snapshots();
  }

}
