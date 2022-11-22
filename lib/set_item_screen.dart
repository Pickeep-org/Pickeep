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
import 'package:flutter/foundation.dart';

class SetItemScreen extends StatefulWidget {
  Item? curItem;
  String? itemId;

  SetItemScreen({Key? key, this.curItem, this.itemId}) : super(key: key);

  @override
  _SetItemScreenState createState() => _SetItemScreenState();
}

class _SetItemScreenState extends State<SetItemScreen> {
  bool _isSubmitButtonEnabled = false;
  late bool _isNewItem = true;

  // TODO: change to nullable and set default text on build instead
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> _cities = Filters().cities;
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

  String? _selectedPhotoPath;
  File? _photo;
  Image? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.curItem != null) {
      _isNewItem = false;
      _nameTextEditController.text = widget.curItem!.name;
      _descriptionTextEditController.text = widget.curItem!.description;
      _chosenCategories = widget.curItem!.categories;
      _selectedPhotoPath = widget.curItem!.imagePath;
      _image = Image.network(
        _selectedPhotoPath!,
        semanticLabel: "Change image",
      );
    }

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

  Future tryPickImage(ImageSource imageSource) async {
    final pickedFile = await _picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _selectedPhotoPath = pickedFile.path;
        _photo = File(pickedFile.path);
        _image = Image.file(
          _photo!,
        );
      });
    }
  }

  Future uploadFile(String itemId) async {
    if (_photo != null) {
      try {
        final ref =
            firebase_storage.FirebaseStorage.instance.ref('items/$itemId');
        await ref.putFile(_photo!);
        String url = await ref.getDownloadURL();
        await FirestoreItems.instance().updateImageUrl(itemId, url);
        await FirestoreItems.instance().setUploadTime(itemId);
      } catch (e) {
        print('error occured');
      }
    }
  }

  bool shouldSubmitBeEnabled() {
    bool isAllFieldsFullProperly = _nameTextEditController.text.isNotEmpty &&
        _cityTextEditingController.text.isNotEmpty &&
        _descriptionTextEditController.text.isNotEmpty &&
        _chosenCategories.isNotEmpty &&
        _cities.contains(_cityTextEditingController.text) &&
        _chosenCategories.isNotEmpty &&
        _selectedPhotoPath != null;

    if (!_isNewItem) {
      bool isItemChanged = _nameTextEditController.text !=
              widget.curItem!.name ||
          _cityTextEditingController.text != widget.curItem!.city ||
          _addressTextEditorController.text != widget.curItem!.address ||
          _descriptionTextEditController.text != widget.curItem!.description ||
          !listEquals(_chosenCategories, widget.curItem!.categories) ||
          _selectedPhotoPath != widget.curItem!.imagePath;

      return isAllFieldsFullProperly && isItemChanged;
    }

    return isAllFieldsFullProperly;
  }

  @override
  Widget build(BuildContext context) {
    _isSubmitButtonEnabled = shouldSubmitBeEnabled();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title:
                _isNewItem ? const Text('Add item') : const Text('Edit item')),
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
                  autofocus: widget.curItem == null,
                  textInputAction: TextInputAction.next,
                  controller: _nameTextEditController,
                  decoration: const InputDecoration(
                    hintText: "Item's name",
                  ),
                  maxLength: 15,
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
                  options: Filters().cities,
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
                  height: 10,
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  controller: _descriptionTextEditController,
                  focusNode: _descriptionFocusNode,
                  decoration:
                      const InputDecoration(hintText: "Item's description"),
                  maxLength: 150,
                  maxLines: 3,
                ),
                const SizedBox(
                  height: 10,
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
                    onTap: () => _showPicker(context),
                    child: CircleAvatar(
                      radius: 26,
                      child: _selectedPhotoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: _image)
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
                      : () {
                          onSubmitPressed(context);
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                  child: const Text("Submit"),
                )
              ],
            ),
          ),
        ));
  }

  Future onSubmitPressed(BuildContext context) async {
    Item item = Item(
        name: _nameTextEditController.text,
        description: _descriptionTextEditController.text,
        city: _cityTextEditingController.text,
        categories: _chosenCategories,
        address: _addressTextEditorController.text,
        imagePath: "null");

    if (_isNewItem) {
      String itemId = await FirestoreItems.instance()
          .addNewItem(FirebaseAuth.instance.currentUser!.uid, item.toJson());
      await uploadFile(itemId);
    } else {
      item.imagePath = widget.curItem!.imagePath;
      await FirestoreItems.instance().updateItem(widget.itemId!, item.toJson());
      await uploadFile(widget.itemId!);
    }
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final chosenCategoriesResult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FilterScreen(
              filterType: 'CategoryAdd', lastChosen: _chosenCategories)),
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
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library,
                        semanticLabel: "Choose from gallery"),
                    title: const Text('Gallery', semanticsLabel: ""),
                    onTap: () async {
                      await tryPickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera,
                      semanticLabel: "Take a picture"),
                  title: const Text(
                    'Camera',
                    semanticsLabel: "",
                  ),
                  onTap: () async {
                    await tryPickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
