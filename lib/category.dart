import 'dart:convert';

class Category {
  String name;

  Category(
      {required this.name});

  Category.fromJason(Map jsonMap)
      : this(
      name: jsonMap['name']);

  Map<String, String> toJson() {
    return {
      'name': name,
    };
  }
}
