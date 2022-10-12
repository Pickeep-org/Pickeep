import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pickeep/category_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
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

  List<String> locations = Filters().locations;
  List<String> chosen_categories = [];
  String chosen_location = "";
  final TextEditingController nameTextEditController = TextEditingController();
  final TextEditingController descriptionTextEditController =
  TextEditingController();

  File? _photo;
  final ImagePicker _picker = ImagePicker();
  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        // TODO:
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        // TODO:
        print('No image selected.');
      }
    });
  }

  Future uploadFile(String itemId) async {
    if (_photo == null) return;
    final fileName = _photo!.path.split('/').last;
    final destination = 'items/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination);
      await ref.putFile(_photo!);
      String url = await ref.getDownloadURL();
      FirestoreItems.instance().updateImageUrl(itemId, url);
    } catch (e) {
      print('error occured');
    }
  }

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
              Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return locations.where((String option) {
                      return option.startsWith(textEditingValue.text.toUpperCase());
                    });
                  },
                  onSelected: (String selection) {
                    chosen_location = selection;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      decoration:
                      const InputDecoration(hintText: "item's location"),
                      focusNode: fieldFocusNode,
                    );
                  }
              ),
              // Autocomplete<String>(
              //   optionsBuilder: (TextEditingValue textEditingValue) {
              //     return locations
              //         .where((String continent) => continent
              //         .toLowerCase()
              //         .startsWith(textEditingValue.text.toLowerCase()))
              //         .toList();
              //   },
              //   displayStringForOption: (String option) => option,
              //   fieldViewBuilder: (BuildContext context,
              //       TextEditingController fieldTextEditingController,
              //       FocusNode fieldFocusNode,
              //       VoidCallback onFieldSubmitted) {
              //     return TextFormField(
              //       controller: fieldTextEditingController,
              //       decoration:
              //       const InputDecoration(hintText: "item's location"),
              //       focusNode: fieldFocusNode,
              //     );
              //   },
              //   onSelected: (String selection) {
              //     chosen_location = selection;
              //   },
              //   optionsViewBuilder: (BuildContext context,
              //       AutocompleteOnSelected<String> onSelected,
              //       Iterable<String> options) {
              //     return Align(
              //       alignment: Alignment.topLeft,
              //       child: Material(
              //         child: Container(
              //           width: 300,
              //           child: ListView.builder(
              //             padding: EdgeInsets.all(10.0),
              //             itemCount: options.length,
              //             itemBuilder: (BuildContext context, int index) {
              //               final String option = options.elementAt(index);
              //
              //               return GestureDetector(
              //                 onTap: () {
              //                   onSelected(option);
              //                 },
              //                 child: ListTile(
              //                   title: Text(option,
              //                       style:
              //                       const TextStyle(color: Colors.white)),
              //                 ),
              //               );
              //             },
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              // ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: descriptionTextEditController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "item's description"),
                maxLength: 200,
                maxLines: 3,
              ),
              const SizedBox(
                height: 15,
              ),
              OutlinedButton(
                  onPressed: () {
                    _navigateAndDisplaySelection(context);
                  },
                  child: const Text(
                    "Choose item's categories",
                    style: TextStyle(fontSize: 18),
                  )),
              Wrap(
                direction: Axis.horizontal,
                spacing: 5,
                children:
                chosen_categories.map((e) => Chip(label: Text(e))).toList(),
              ),
              const Text(
                "Upload an image for the item:",
                style: TextStyle(fontSize: 17),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    radius: 26,
                    child: _photo != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _photo!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                        : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(45)),
                      width: 45,
                      height: 45,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () async{
                  Item newItem = Item(
                      name: nameTextEditController.text,
                      description: descriptionTextEditController.text,
                      location: chosen_location,
                      categories: chosen_categories, image: _photo!.path.split('/').last);

                  String itemId = await FirestoreItems.instance().addNewItem(FirebaseAuth.instance.currentUser!.uid, newItem.toJson());
                  uploadFile(itemId);
                  Navigator.pop(context);
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

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Gallery'),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
