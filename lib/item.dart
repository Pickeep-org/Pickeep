// Data structure that holds an item document of Firestore.
// Class fields:
// 1. String name
// 2. String description
// 3. List categories
// 4. String city
// 5. String address
// 6. String image - The path to the image in Firestorage
// The class includes casting methods to/from Json, in order to work with the
// database.
class Item {
  String name;
  String description;
  List categories;
  String city;
  String address;
  String? imagePath;

  Item(
      {required this.name,
      required this.description,
      required this.categories,
      required this.city,
      required this.address,
      required this.imagePath});

  Item.fromJason(Map jsonMap)
      : this(
            name: jsonMap['name'],
            description: jsonMap['description'],
            categories: jsonMap['categories'],
            address: jsonMap['address'],
            imagePath: jsonMap['image'],
            city: jsonMap['location']);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categories': categories,
      'address': address,
      'location': city,
      'image': imagePath
    };
  }
}
