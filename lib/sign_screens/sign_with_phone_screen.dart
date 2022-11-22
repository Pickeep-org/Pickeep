import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_authentication/firebase_phone_authentication.dart';
import '../main.dart';

extension PhoneValidator on String {
  bool isValid() {
    return false;
  }
}
showAlertPopup(BuildContext context, String title, String detail, Function onClick) async {



}
class SignWithPhoneScreen extends StatelessWidget {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  showAlertDialog(BuildContext context, Function onClick) {
    String smsCode = "";
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
                FirebaseAuth auth = FirebaseAuth.instance;
                onClick(_codeController.text.trim());
                Navigator.pop(context, 'Done');
              },
            )
          ],
        )
    );
    return smsCode;
  }
  SignWithPhoneScreen({Key? key}) : super(key: key);

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Sign in using phone')),
        body:  Padding(
            padding: const EdgeInsets.all(10.0),
            child:Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(
                            Icons.local_phone),
                        border: OutlineInputBorder(),
                        hintText: "Please insert your phone number"),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (input) =>
                    input!.isValid() ? "Invalid phone number" : null,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    child: const Text("Sign in"),
                    onPressed: () async {
                      FirebasePhoneAuthentication fp = FirebasePhoneAuthentication.instance();
                      fp.initInstance(phone: _phoneController.text, context: context);
                      await fp.signIn();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) => Pickeep()),
                              (route) => false);

                    },
                  ),
                ])));
  }
}