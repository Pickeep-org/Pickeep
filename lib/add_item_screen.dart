import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:pickeep/filter_screen.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firestore/firestore_items.dart';
import 'package:pickeep/text_from_field_autocomplete.dart';
import 'item.dart';
import 'package:pickeep/CurrentUserInfo.dart';

class AddItemScreen extends StatefulWidget {
  Item? curItem;
  String? itemId;
  bool isEdit = false;
  AddItemScreen({Key? key, this.curItem,  this.itemId, this.isEdit = false}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  bool _isSubmitButtonEnabled = false;

  // TODO: change to nullable and set default text on build instead
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _cities = Filters().locations;
  List _chosenCategories = [];
  final TextEditingController _nameTextEditController = TextEditingController();
  final TextEditingController _cityTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditController =
      TextEditingController();
  final TextEditingController _addressTextEditorController =
      TextEditingController();

  late FocusNode _cityFocusNode;
  late FocusNode _addressFocusNode;
  late FocusNode _descriptionFocusNode;

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
    _cityTextEditingController.text = CurrentUserInfo().user.city;
    _addressTextEditorController.text = CurrentUserInfo().user.address;

    _cityFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameTextEditController.dispose();
    _cityTextEditingController.dispose();
    _descriptionTextEditController.dispose();
    _addressTextEditorController.dispose();

    _cityFocusNode.dispose();
    _addressFocusNode.dispose();
    _descriptionFocusNode.dispose();

    super.dispose();
  }

  bool isAllRequiredFieldNotEmpty() {
    return _nameTextEditController.text.isNotEmpty &&
        _cityTextEditingController.text.isNotEmpty &&
        _descriptionTextEditController.text.isNotEmpty &&
        _chosenCategories.isNotEmpty;
  }

  bool shouldSubmitBeEnabled(){
    return isAllRequiredFieldNotEmpty() &&
        _cities.contains(_cityTextEditingController.text) &&
        _chosenCategories.isNotEmpty &&
        _photo != null;;
  }

  @override
  Widget build(BuildContext context) {
    _isSubmitButtonEnabled = shouldSubmitBeEnabled();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Add item')),
        body: Form(
          key: _formKey,
          onChanged: () {
            if (_isSubmitButtonEnabled != shouldSubmitBeEnabled()) {
              setState(() => _isSubmitButtonEnabled = !_isSubmitButtonEnabled);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  keyboardType: TextInputType.name,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  controller: _nameTextEditController,
                  decoration: InputDecoration(
                    hintText: "Item's name",
                  ),
                  maxLength: 50,
                  onEditingComplete: () {
                    if (_addressTextEditorController.text.isEmpty) {
                      _addressFocusNode.requestFocus();
                    } else {
                      _descriptionFocusNode.requestFocus();
                    }
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFromFieldAutocomplete(
                  textEditingController: _cityTextEditingController,
                  options: Filters().locations,
                  focusNode: _cityFocusNode,
                  nextFocusNode: _addressFocusNode,
                  onSelected: (String selection) {
                    _addressFocusNode.requestFocus();
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  focusNode: _addressFocusNode,
                  controller: _addressTextEditorController,
                  decoration: const InputDecoration(
                      hintText: "Item's address (optional)"),
                  maxLength: 50,
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: _descriptionTextEditController,
                  focusNode: _descriptionFocusNode,
                  decoration:
                      const InputDecoration(hintText: "Item's description"),
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
                      style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : null),
                    )),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 5,
                  children: _chosenCategories
                      .map((e) => Chip(label: Text(e)))
                      .toList(),
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
                    onTap: () => (setState(() {
                      _showPicker(context);
                    })),
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
                  onPressed: !_isSubmitButtonEnabled
                      ? null
                      : () async {
                          await onSubmitPressed(context);
                        },
                  child: const Text("Submit"),
                )
              ],
            ),
          ),
        ));
  }

  Future onSubmitPressed(BuildContext context) async {
    Item newItem = Item(
        name: _nameTextEditController.text,
        description: _descriptionTextEditController.text,
        city: _cityTextEditingController.text,
        categories: _chosenCategories,
        address: _addressTextEditorController.text,
        image: _photo!.path.split('/').last);

    String itemId = await FirestoreItems.instance()
        .addNewItem(FirebaseAuth.instance.currentUser!.uid, newItem.toJson());
    uploadFile(itemId);
    Navigator.of(context).pop();
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final chosenCategoriesResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FilterScreen(filterType: 'CategoryAdd', lastChosen: _chosenCategories)),
    );

    setState(() {
      if (chosenCategoriesResult != null) {
        _chosenCategories = chosenCategoriesResult;
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
