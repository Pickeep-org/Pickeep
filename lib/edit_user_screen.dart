// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickeep/contact_Info.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/text_from_field_autocomplete.dart';

import '../favorites.dart';
import '../filters.dart';
import 'CurrentUserInfo.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  List<String> locations = Filters().cities;
  final TextEditingController _firstNameTextEditingController;
  final TextEditingController _lastNameTextEditingController;
  final TextEditingController _phoneNumberTextEditingController;
  final TextEditingController _cityTextEditingController;
  final TextEditingController _addressTextEditingController;

  late FocusNode _cityFocusNode;
  late FocusNode _addressFocusNode;

  _EditProfileScreenState()
      : _firstNameTextEditingController = TextEditingController(),
        _lastNameTextEditingController = TextEditingController(),
        _phoneNumberTextEditingController = TextEditingController(),
        _cityTextEditingController = TextEditingController(),
        _addressTextEditingController = TextEditingController();

  bool _isDoneButtonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _firstNameTextEditingController.text = CurrentUserInfo().user.firstName;
    _lastNameTextEditingController.text = CurrentUserInfo().user.lastName;
    _phoneNumberTextEditingController.text = CurrentUserInfo().user.phoneNumber;
    _cityTextEditingController.text = CurrentUserInfo().user.city;
    _addressTextEditingController.text = CurrentUserInfo().user.address;

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

    _cityFocusNode.dispose();
    _addressFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
            title: Text('User Information'),
          leading: IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(Icons.arrow_back)),),
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
                    keyboardType: TextInputType.name,
                    controller: _firstNameTextEditingController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'First name',
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _lastNameTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Last name'),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Phone number'),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFromFieldAutocomplete(
                    textEditingController: _cityTextEditingController,
                    options: Filters().cities,focusNode: _cityFocusNode,nextFocusNode: _addressFocusNode,
                    onSelected: (String selection) {
                      _addressFocusNode.requestFocus();
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
                    keyboardType: TextInputType.streetAddress,
                    controller: _addressTextEditingController,
                    focusNode: _addressFocusNode,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: 'Address'),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: !_isDoneButtonEnabled ? null : onPressedSign,
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


  Future onPressedSign() async {
      ContactInfo contactInfo = ContactInfo(
          firstName: _firstNameTextEditingController.text,
          lastName: _lastNameTextEditingController.text,
          phoneNumber: _phoneNumberTextEditingController.text,
          city: _cityTextEditingController.text,
          address: _addressTextEditingController.text);

      FirestoreUser().setUserInfo(
          FirebaseAuth.instance.currentUser!.uid, contactInfo.toJson());
          CurrentUserInfo().updateUser(contactInfo);
          Navigator.pop(context);
  }
}
