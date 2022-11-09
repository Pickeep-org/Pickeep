import 'dart:convert';

class Item {
  String name;
  String description;
  List categories;
  String city;
  String address;
  String image;

  Item(
      {required this.name,
        required this.description,
        required this.categories,
        required this.city,
        required this.address,
	required this.image});

  Item.fromJason(Map jsonMap)
      : this(
      name: jsonMap['name'],
      description: jsonMap['description'],
      categories: jsonMap['categories'],
      address: jsonMap['address'],
      image: jsonMap['image'] ,
      city: jsonMap['location']);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categories': categories,
      'address': address,
      'location': city,
      'image': image
    };
  }
}
