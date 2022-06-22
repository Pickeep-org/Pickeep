import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreLocations {
  final CollectionReference _locations;

  FirestoreLocations.instance() :
        _locations = FirebaseFirestore.instance.collection('Locations');

  Future<QuerySnapshot> getLocationsOrderByCity() {
    return _locations.orderBy('city').get();
  }
}
