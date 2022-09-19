// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickeep/contact_Info.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:pickeep/home_screen.dart';

import '../favorites.dart';
import '../filters.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({Key? key}) : super(key: key);

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  final TextEditingController _firstNameTextEditingController;
  final TextEditingController _lastNameTextEditingController;
  final TextEditingController _phoneNumberTextEditingController;
  final TextEditingController _addressTextEditingController;

  _ContactInfoScreenState()
      : _firstNameTextEditingController = TextEditingController(),
        _lastNameTextEditingController = TextEditingController(),
        _phoneNumberTextEditingController = TextEditingController(),
        _addressTextEditingController = TextEditingController();

  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _phoneNumberFocusNode;
  late FocusNode _addressFocusNode;

  bool _isButtonEnabled = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
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
    _addressFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true, title: Text('Sign up with email')),
      body: Form(
        key: _formKey,
        onChanged: () {
          if (_isButtonEnabled == isEnyFieldEmpty()) {
            setState(() => _isButtonEnabled = !_isButtonEnabled);
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
                  TextFormField(
                    focusNode: _phoneNumberFocusNode,
                    keyboardType: TextInputType.phone,
                    controller: _phoneNumberTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Phone number'),
                    onEditingComplete: () => _addressFocusNode.requestFocus(),
                  ),
                  TextFormField(
                    focusNode: _addressFocusNode,
                    keyboardType: TextInputType.streetAddress,
                    controller: _addressTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: 'Address'),
                    onEditingComplete: () => _addressFocusNode.unfocus(),
                  )
                ],
              ),
              ElevatedButton(
                onPressed: !_isButtonEnabled ? null : onPressedSign,
                child: Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isEnyFieldEmpty() {
    return _firstNameTextEditingController.text.isEmpty ||
        _lastNameTextEditingController.text.isEmpty ||
        _phoneNumberTextEditingController.text.isEmpty ||
        _addressTextEditingController.text.isEmpty;
  }

  Future onPressedSign() async {
    if (_firstNameTextEditingController.text.isNotEmpty &&
        _lastNameTextEditingController.text.isNotEmpty &&
        _phoneNumberTextEditingController.text.isNotEmpty &&
        _addressTextEditingController.text.isNotEmpty) {
      ContactInfo contactInfo = ContactInfo(
          firstName: _firstNameTextEditingController.text,
          lastName: _lastNameTextEditingController.text,
          phoneNumber: _phoneNumberTextEditingController.text,
          address: _addressTextEditingController.text);

      FirestoreUser().setUserInfo(
          FirebaseAuth.instance.currentUser!.uid, contactInfo.toJson());
      await Favorites().getFromDB(FirebaseAuth.instance.currentUser!.uid);
      await Filters().loadFilters();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
          (route) => false);
    }
  }
}
