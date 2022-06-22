import 'package:flutter/material.dart';
import 'package:pickeep/category_screen.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firestore/firestore_items.dart';

import 'item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // TODO: change to nullable and set default text on build instead
  String chosen_location = "haifa";

  List<String> chosen_categories = [];
  final TextEditingController nameTextEditController = TextEditingController();
  final TextEditingController descriptionTextEditController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    nameTextEditController.addListener(() {
      final String text = nameTextEditController.text.toLowerCase();
      nameTextEditController.value = nameTextEditController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    descriptionTextEditController.addListener(() {
      final String text = descriptionTextEditController.text.toLowerCase();
      descriptionTextEditController.value =
          descriptionTextEditController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    nameTextEditController.dispose();
    descriptionTextEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Add item')),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameTextEditController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "item's name"),
                maxLength: 50,
              ),
              TextFormField(
                controller: descriptionTextEditController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "item's description"),
                maxLength: 200,
                maxLines: 3,
              ),
              Row(children: [
                DropdownButton(
                  isDense: false,
                  borderRadius: BorderRadius.circular(10),
                  value: chosen_location,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: Filters().locations.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  onChanged: (String? location) {
                    setState(() {
                      chosen_location = location!;
                    });
                  },
                ),
              ]),
              //const Text(""),
              Row(children: [
                TextButton(
                    onPressed: () {
                      _navigateAndDisplaySelection(context);
                    },
                    child: const Text(
                      "Choose item's categories",
                      style: TextStyle(fontSize: 18),
                    ))
              ]),
              Wrap(
                direction: Axis.horizontal,
                spacing: 5,
                children:
                    chosen_categories.map((e) => Chip(label: Text(e))).toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  Item newItem = Item(
                      name: nameTextEditController.text,
                      description: descriptionTextEditController.text,
                      location: chosen_location,
                      categories: chosen_categories);

                  FirestoreItems.instance().addNewItem(newItem.toJson());
                },
                child: const Text("Submit"),
              )
            ],
          ),
        ));
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // TODO: more elegant
    final chosen_categories_result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryScreen()),
    );


    setState(() {
      if (chosen_categories_result != null) {
        chosen_categories = chosen_categories_result;
      }
    });
  }
}
