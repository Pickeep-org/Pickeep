import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:async/async.dart';

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

  Stream<QuerySnapshot> getItemsOrderByUpload(List cats, List locs, String filterType) {
    if(filterType == 'None'){
      return _items
          .orderBy('uploadTime', descending: true)
          .snapshots();
    }
    if(filterType == 'Both'){
      List<Stream<QuerySnapshot>> streams = [];
      Stream<QuerySnapshot> s_1 = _items
          .where('item.location', whereIn: locs)
          .where('item.categories', arrayContains: cats[0])
          .orderBy('uploadTime', descending: true)
          .snapshots();
      streams.add(s_1);
      for(int i = 0; i<cats.length; i++){
        Stream<QuerySnapshot> s_2 = _items
            .where('item.location', whereIn: locs)
            .where('item.categories', arrayContains: cats[i])
            .orderBy('uploadTime', descending: true)
            .snapshots();
        streams.add(s_2);
      }
      return StreamGroup.merge(streams);
    }
    if(filterType == 'Category'){
      return _items
          .where('item.categories', arrayContainsAny: cats)
          .orderBy('uploadTime', descending: true)
          .snapshots();
    }
    else {
      if(locs.length > 10){
        List chunks = [];
        List<Stream<QuerySnapshot>> streams = [];
        int chunkSize = 10;
        for (int i = 0; i < locs.length; i += chunkSize) {
          chunks.add(locs.sublist(i, i+chunkSize > locs.length ? locs.length : i + chunkSize));
        }
        for(int i = 0; i<chunks.length; i++) {
          Stream<QuerySnapshot> s = _items
              .where('item.location', whereIn: chunks[i])
              .orderBy('uploadTime', descending: true)
              .snapshots();
          streams.add(s);
        }
        return StreamGroup.merge(streams);
      }
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
