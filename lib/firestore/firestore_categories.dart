import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCategories {
  final CollectionReference _categories;

  FirestoreCategories.instance() :
        _categories = FirebaseFirestore.instance.collection('Categories');

  Future<QuerySnapshot> getCategoriesOrderByName() {
    return _categories.orderBy('name').get();
  }
}
