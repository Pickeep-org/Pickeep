// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickeep/text_from_field_autocomplete.dart';
import 'package:pickeep/contact_Info.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import '../CurrentUserInfo.dart';
import '../filters.dart';
import '../main.dart';

class ContactInfoScreen extends StatefulWidget {
  bool isEdit;
  ContactInfoScreen({Key? key, this.isEdit = false}) : super(key: key);
  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  List<String> locations = Filters().cities;
  final TextEditingController _firstNameTextEditingController;
  final TextEditingController _lastNameTextEditingController;
  final TextEditingController _phoneNumberTextEditingController;
  final TextEditingController _cityTextEditingController;
  final TextEditingController _addressTextEditingController;

  _ContactInfoScreenState()
      : _firstNameTextEditingController = TextEditingController(),
        _lastNameTextEditingController = TextEditingController(),
        _phoneNumberTextEditingController = TextEditingController(),
        _cityTextEditingController = TextEditingController(),
        _addressTextEditingController = TextEditingController();

  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _phoneNumberFocusNode;
  late FocusNode _cityFocusNode;
  late FocusNode _addressFocusNode;

  bool _isDoneButtonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    print(widget.isEdit.toString());
    print(CurrentUserInfo().user.firstName);
    if(widget.isEdit){

      _firstNameTextEditingController.text = CurrentUserInfo().user.firstName;
      _lastNameTextEditingController.text = CurrentUserInfo().user.lastName;
      _phoneNumberTextEditingController.text = CurrentUserInfo().user.phoneNumber;
      _cityTextEditingController.text = CurrentUserInfo().user.city;
      _addressTextEditingController.text = CurrentUserInfo().user.address;
    }
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
    _cityFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _cityFocusNode.dispose();
    _addressFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: Text('User Information'),
      leading: widget.isEdit? IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: const Icon(Icons.arrow_back)): null),
      body: Form(
        key: _formKey,
        onChanged: () {
          if (_isDoneButtonEnabled !=
              (isAllFieldNotEmpty() &&
                  locations.contains(_cityTextEditingController.text))) {
            setState(() => _isDoneButtonEnabled = !_isDoneButtonEnabled);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.name,
                    controller: _firstNameTextEditingController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'First name',
                    ),
                    onEditingComplete: () => _lastNameFocusNode.requestFocus(),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFormField(
                    focusNode: _lastNameFocusNode,
                    keyboardType: TextInputType.name,
                    controller: _lastNameTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Last name'),
                    onEditingComplete: () =>
                        _phoneNumberFocusNode.requestFocus(),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFormField(
                    focusNode: _phoneNumberFocusNode,
                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Phone number'),
                    onEditingComplete: () => _cityFocusNode.requestFocus(),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFromFieldAutocomplete(
                    textEditingController: _cityTextEditingController,
                    options: Filters().cities,
                    focusNode: _cityFocusNode,
                    nextFocusNode: _addressFocusNode,
                    onSelected: (String selection) {
                      if (_isDoneButtonEnabled !=
                          (isAllFieldNotEmpty() &&
                              locations
                                  .contains(_cityTextEditingController.text))) {
                        setState(
                            () => _isDoneButtonEnabled = !_isDoneButtonEnabled);
                      }
                    },
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFormField(
                    focusNode: _addressFocusNode,
                    keyboardType: TextInputType.streetAddress,
                    controller: _addressTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: 'Address'),
                    onEditingComplete: () => _addressFocusNode.unfocus(),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: !_isDoneButtonEnabled ? null : onPressedDone,
                child: Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isAllFieldNotEmpty() {
    return _firstNameTextEditingController.text.isNotEmpty &&
        _lastNameTextEditingController.text.isNotEmpty &&
        _phoneNumberTextEditingController.text.isNotEmpty &&
        _cityTextEditingController.text.isNotEmpty &&
        _addressTextEditingController.text.isNotEmpty;
  }

  Future onPressedDone() async {
    ContactInfo contactInfo = ContactInfo(
        firstName: _firstNameTextEditingController.text,
        lastName: _lastNameTextEditingController.text,
        phoneNumber: _phoneNumberTextEditingController.text,
        city: _cityTextEditingController.text,
        address: _addressTextEditingController.text);

    FirestoreUser().setUserInfo(
        FirebaseAuth.instance.currentUser!.uid, contactInfo.toJson());

    widget.isEdit
        ? {CurrentUserInfo().updateUser(contactInfo), Navigator.pop(context)}
    : Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => Pickeep()),
        (route) => false);
  }
}
