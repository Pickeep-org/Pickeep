import 'dart:convert';

class Item {
  String name;
  String description;
  List categories;
  String location;

  Item(
      {required this.name,
      required this.description,
      required this.categories,
      required this.location});

  Item.fromJason(Map jsonMap)
      : this(
            name: jsonMap['name'],
            description: jsonMap['description'],
            categories: jsonMap['categories'],
            location: jsonMap['location']);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'categories': categories,
      'location': location,
    };
  }
}
