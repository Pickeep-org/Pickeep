import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../firebase_authentication/firebase_phone_authentication.dart';
import '../main.dart';

// Handles the signing up of a new user or signing in of a existing user using
// phone authentication method. this class wrap the Firebase Phone Authentication.
// Class fields: Text Controllers - hold the information given by the user.
class SignWithPhoneScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  showAlertDialog(BuildContext context, Function onClick) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: const Text("Enter SMS Code:"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text("Done"),
                  onPressed: () {
                    onClick(_codeController.text.trim());
                    Navigator.pop(context, 'Done');
                  },
                )
              ],
            ));
  }

  SignWithPhoneScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sign in using phone')),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(children: [
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.local_phone),
                    border: OutlineInputBorder(),
                    hintText: "Please insert your phone number"),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (input) => input!.length <= 10
                    ? null
                    : "Invalid phone number, must be 10 digits",
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                child: const Text("Sign in"),
                onPressed: () async {
                  final navigator = Navigator.of(context);

                  FirebasePhoneAuthentication fp =
                      FirebasePhoneAuthentication.instance();
                  fp.initInstance(
                      phone: '+972${_phoneController.text}', context: context);
                  await fp.signIn();
                  navigator.pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => const Pickeep()),
                      (route) => false);
                },
              ),
            ])));
  }
}
