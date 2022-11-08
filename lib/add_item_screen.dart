import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:pickeep/category_screen.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/text_from_field_autocomplete.dart';
import 'item.dart';
import 'package:pickeep/CurrentUserInfo.dart';


class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // TODO: change to nullable and set default text on build instead
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool formIsValid = false;
  List<String> locations = Filters().locations;
  List<String> chosenCategories = [];
  String chosenLocation = "";
  final TextEditingController nameTextEditController = TextEditingController();
  final TextEditingController descriptionTextEditController =
      TextEditingController();
  final TextEditingController _cityTextEditingController = TextEditingController();
  final TextEditingController addressTextEditorController = TextEditingController();

  late FocusNode _cityFocusNode;
  late FocusNode _addressFocusNode;

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
      final ref = firebase_storage.FirebaseStorage.instance.ref(destination);
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
    addressTextEditorController.text = CurrentUserInfo().user.address;
    nameTextEditController.addListener(() {
      final String text = nameTextEditController.text;
      nameTextEditController.value = nameTextEditController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    _cityTextEditingController.text = CurrentUserInfo().user.city;
    descriptionTextEditController.addListener(() {
      final String text = descriptionTextEditController.text;
      descriptionTextEditController.value =
          descriptionTextEditController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    addressTextEditorController.addListener(() {
      String text = addressTextEditorController.text;
      addressTextEditorController.value = addressTextEditorController.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });

    _cityFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameTextEditController.dispose();
    descriptionTextEditController.dispose();
    addressTextEditorController.dispose();

    _cityFocusNode.dispose();
    _addressFocusNode.dispose();
    
    super.dispose();
  }

  static String _displayStringForOption(String option) => option;
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
  bool isAnyFieldEmpty() {
    return nameTextEditController.text.isEmpty ||
        descriptionTextEditController.text.isEmpty ||
        chosenLocation.isEmpty || chosenCategories.isEmpty || addressTextEditorController.text.isEmpty;
  }
  @override
  Widget build(BuildContext context) {
    chosenLocation = CurrentUserInfo().user.city;
    bool _validate_name = false;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Add item')),
        body: Form(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameTextEditController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(), hintText: "item's name",
                      errorText: _validate_name ? "this field is required" : null),
                  maxLength: 50,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.text,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (input) =>
                  input!.isEmpty ? "this field is required" : null,

                ),
                const SizedBox(
                  height: 5,
                ),
            Column(children: [
              TextFromFieldAutocomplete(
                textEditingController: _cityTextEditingController,
                options: Filters().locations,focusNode: _cityFocusNode,nextFocusNode: _addressFocusNode,
                onSelected: (String selection) {
                  _addressFocusNode.requestFocus();
                },
              ),
              TextFormField(
                focusNode: _addressFocusNode,
                controller: addressTextEditorController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "item's address"),
                maxLength: 50,
              ),
            ],),
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
                    child: Text(
                      "Choose item's categories",
                      style: TextStyle(fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ?
                      Colors.white : null),
                    )),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 5,
                  children:
                      chosenCategories.map((e) => Chip(label: Text(e))).toList(),
                ),
                const Text(
                  "Upload an image for the item:",
                  style: TextStyle(fontSize: 17),
                ),
                const SizedBox(
                  height: 5,
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
                                semanticLabel: "Upload an image",
                                color: Colors.grey[800],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      if (isAnyFieldEmpty()) {
                        _validate_name = true;

                      } else {
                        _validate_name = false;
                      }
                    });
                    if(!_validate_name){
                      Item newItem = Item(
                          name: nameTextEditController.text,
                          description: descriptionTextEditController.text,
                          location: chosenLocation,
                          categories: chosenCategories,
                          address: addressTextEditorController.text,
                          /*image: _photo!
                              .path
                              .split('/')
                              .last);
                           */
                          image: "");

                      String itemId = await FirestoreItems.instance().addNewItem(
                          FirebaseAuth.instance.currentUser!.uid,
                          newItem.toJson());
                      //uploadFile(itemId);
                      Navigator.pop(context);
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Some fields are empty")));
                    }

                  },
                  child: const Text("Submit"),
                )
              ],
            ),
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
        chosenCategories = chosen_categories_result;
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
                      leading: const Icon(Icons.photo_library, semanticLabel: "Choose from gallery"),
                      title: const Text('Gallery', semanticsLabel: ""),
                      onTap: () {
                        imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: const Icon(Icons.photo_camera, semanticLabel: "Take a picture"),
                    title: const Text('Camera', semanticsLabel: "",),
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
