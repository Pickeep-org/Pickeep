import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:pickeep/category_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'item.dart';

class EditItemScreen extends StatefulWidget {
  Item item;
  final String itemId;
  EditItemScreen({Key? key, required this.item, required this.itemId}) : super(key: key);
  @override
  _EditItemScreenState createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  // TODO: change to nullable and set default text on build instead
  List<String> locations = Filters().locations;
  List chosen_categories = [];
  String chosen_location = "";
  final TextEditingController nameTextEditController = TextEditingController();
  final TextEditingController descriptionTextEditController =
  TextEditingController();
  final TextEditingController addressTextEditorController = TextEditingController();

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

  Future updateFile() async {
    if (_photo == null) return;
    final fileName = _photo!.path.split('/').last;
    final destination = 'items/$fileName';
    //widget.item.image
    try {

      final curref = firebase_storage.FirebaseStorage.instance.ref('items/${widget.item.image}');
      await curref.delete();
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination);
      await ref.putFile(_photo!);
      String url = await ref.getDownloadURL();
      FirestoreItems.instance().updateImageUrl(widget.itemId, url);
    } catch (e) {
      print('error occured');
    }
  }

  @override
  void initState() {
    super.initState();
    chosen_categories = widget.item.categories;
    chosen_location = widget.item.location;
    nameTextEditController.addListener(() {
      String text = nameTextEditController.text.toLowerCase();
      nameTextEditController.value = nameTextEditController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    descriptionTextEditController.addListener(() {
      String text = descriptionTextEditController.text.toLowerCase();
      descriptionTextEditController.value =
          descriptionTextEditController.value.copyWith(
            text: text,
            selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
            composing: TextRange.empty,
          );
    });
    addressTextEditorController.addListener(() {
      String text = addressTextEditorController.text.toLowerCase();
      addressTextEditorController.value = addressTextEditorController.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    nameTextEditController.dispose();
    descriptionTextEditController.dispose();
    addressTextEditorController.dispose();
    super.dispose();
  }

  String fixLoc(String loc){
    if(loc.isEmpty){
      return loc;
    }
    if(!loc.contains(" ")){
      return loc.toLowerCase().capitalize;
    }
    List<String> splitted = [];
    for(String st in loc.split(" ")){
      splitted.add(st.toLowerCase().capitalize);
    }
    return splitted.join(" ");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Edit item')),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameTextEditController..text = widget.item.name,
                decoration: const InputDecoration(
                    border: OutlineInputBorder()),
                maxLength: 50,
              ),
              Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return locations.where((String option) {
                      return option.startsWith(fixLoc(textEditingValue.text));
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
                      controller: fieldTextEditingController..text = widget.item.location,
                      decoration:
                      const InputDecoration(hintText: "item's location"),
                      focusNode: fieldFocusNode,
                    );
                  }
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: addressTextEditorController..text = widget.item.address,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "item's address"),
                maxLength: 50,
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                //initialValue: widget.item.description,
                controller: descriptionTextEditController..text = widget.item.description,

                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    //prefixText: ,
                    //prefixIcon: TextFormField(widget.item.description)),
                ),//hintText: widget.item.description,),
                //prefixStyle: TextStyle. ),
                    //helperText: widget.item.description),
                    //hintText: widget.item.description),
          maxLength: 200,
                maxLines: 3,
              ),
              const SizedBox(
                height: 5,
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
                      child: Image(image: NetworkImage(widget.item.image),
                      )
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  Item newItem = Item(
                      name: nameTextEditController.text,
                      description: descriptionTextEditController.text,
                      location: chosen_location,
                      address: addressTextEditorController.text,
                      categories: chosen_categories, image: _photo != null ? _photo!.path.split('/').last  : widget.item.image);

                  FirestoreItems.instance().updateItem(widget.itemId, newItem.toJson());
                  updateFile();

                  Navigator.pop(context, newItem);
                },
                child: const Text("Update item"),
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
