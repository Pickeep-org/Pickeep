// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickeep/contact_Info.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import '../filters.dart';
import '../main.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({Key? key}) : super(key: key);

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  List<String> locations = Filters().locations;
  String chosenLocation = "";
  final TextEditingController _firstNameTextEditingController;
  final TextEditingController _lastNameTextEditingController;
  final TextEditingController _phoneNumberTextEditingController;
  final TextEditingController _addressTextEditingController;

  _ContactInfoScreenState()
      : _firstNameTextEditingController = TextEditingController(),
        _lastNameTextEditingController = TextEditingController(),
        _phoneNumberTextEditingController = TextEditingController(),
        _addressTextEditingController = TextEditingController();
  String chosen_location = "";
  late FocusNode _firstNameFocusNode;
  late FocusNode _lastNameFocusNode;
  late FocusNode _phoneNumberFocusNode;
  late FocusNode _locationFocusNode;
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
    _locationFocusNode = FocusNode();
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
    _locationFocusNode.dispose();
    _addressFocusNode.dispose();

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
                    onEditingComplete: () => _locationFocusNode.requestFocus(),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return   Filters().locations.where((String option) {
                          return option.startsWith(fixLoc(textEditingValue.text));
                        });
                      },
                      onSelected: (String selection) {
                        chosen_location = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          _locationFocusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: fieldTextEditingController..text = chosen_location,
                          decoration:
                          const InputDecoration(labelText: "City"),
                          focusNode: _locationFocusNode,
                          onEditingComplete: () => _addressFocusNode.requestFocus(),
                        );
                      }
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
                  // Autocomplete<String>(
                  //     optionsBuilder: (TextEditingValue textEditingValue) {
                  //       if (textEditingValue.text == '') {
                  //         return const Iterable<String>.empty();
                  //       }
                  //       return locations.where((String option) {
                  //         return option.startsWith(fixLoc(textEditingValue.text));
                  //       });
                  //     }, onSelected: (String selection) {
                  //   chosenLocation = selection;
                  // },
                  //     fieldViewBuilder: (BuildContext context,
                  //         TextEditingController fieldTextEditingController,
                  //         FocusNode fieldFocusNode,
                  //         VoidCallback onFieldSubmitted) {
                  //       return TextFormField(
                  //         controller: fieldTextEditingController,
                  //         decoration: const InputDecoration(hintText: "City"),
                  //         focusNode: fieldFocusNode,
                  //       );}),
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
          city: chosenLocation,
          address: _addressTextEditingController.text);

      FirestoreUser().setUserInfo(
          FirebaseAuth.instance.currentUser!.uid, contactInfo.toJson());
       Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute(builder: (BuildContext context) => Pickeep()),
           (route) => false);
    }
  }
}
