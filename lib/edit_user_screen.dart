// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickeep/contact_Info.dart';
import 'package:pickeep/firestore/firestore_users.dart';
import 'package:pickeep/filters.dart';

import '../favorites.dart';
import '../filters.dart';
import 'CurrentUserInfo.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String chosenLocation = CurrentUserInfo().user.city;
  final TextEditingController _firstNameTextEditingController;
  final TextEditingController _lastNameTextEditingController;
  final TextEditingController _phoneNumberTextEditingController;
  final TextEditingController _addressTextEditingController;

  _EditProfileScreenState()
      : _firstNameTextEditingController = TextEditingController(),
        _lastNameTextEditingController = TextEditingController(),
        _phoneNumberTextEditingController = TextEditingController(),
        _addressTextEditingController = TextEditingController();

  bool _isButtonEnabled = false;

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
    _addressTextEditingController.text = CurrentUserInfo().user.address;

  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
      appBar: AppBar(
            title: Text('User Information'),
            leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: const Icon(Icons.arrow_back)),),
      body: Form(
        key: _formKey,
        onChanged: () {
          if (_isButtonEnabled == isAnyFieldEmpty()) {
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
                  Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          chosenLocation = "";
                          return const Iterable<String>.empty();
                        }
                        return Filters().locations.where((String option) {
                          return option.startsWith(fixLoc(textEditingValue.text));
                        });
                      },
                      onSelected: (String selection) {
                        chosenLocation = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldTextEditingController,
                          FocusNode fieldFocusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: fieldTextEditingController..text = chosenLocation,
                          decoration:
                          const InputDecoration(labelText: "Location"),
                          focusNode: fieldFocusNode,
                        );
                      }
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.streetAddress,
                    controller: _addressTextEditingController,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: 'Address'),
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

  bool isAnyFieldEmpty() {
    //print(chosenLocation);
    return _firstNameTextEditingController.text.isEmpty ||
        _lastNameTextEditingController.text.isEmpty ||
        _phoneNumberTextEditingController.text.isEmpty ||
        _addressTextEditingController.text.isEmpty || chosenLocation.isEmpty;
  }

  Future onPressedSign() async {
      ContactInfo contactInfo = ContactInfo(
          firstName: _firstNameTextEditingController.text,
          lastName: _lastNameTextEditingController.text,
          phoneNumber: _phoneNumberTextEditingController.text,
          city: chosenLocation,
          address: _addressTextEditingController.text);

      FirestoreUser().setUserInfo(
          FirebaseAuth.instance.currentUser!.uid, contactInfo.toJson());
          CurrentUserInfo().updateUser(contactInfo);
          Navigator.pop(context);
      // await Favorites().getFromDB(FirebaseAuth.instance.currentUser!.uid);
      // await Filters().loadFilters();
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
      //     (route) => false);
  }
}
