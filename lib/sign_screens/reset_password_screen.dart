import 'package:flutter/material.dart';
import 'package:pickeep/firebase_authentication/firebase_email_authentication.dart';

extension EmailValidator on String {
  bool isValid() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

class ResetPassScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _authService = FirebaseEmailAuthentication.instance();

  ResetPassScreen({Key? key}) : super(key: key);
  showAlertDialog(BuildContext context) {
    Widget OkButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Hello"),
      content: const Text("Please check your mailbox for further instructions"),
      actions: [
        OkButton,
      ],
    );
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: const Text('Password Recovery')),
        body:  Padding(
    padding: const EdgeInsets.all(10.0),
    child:Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email),
                            border: OutlineInputBorder(),
                            hintText: "Please insert your email"),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (input) =>
                            input!.isValid() ? null : "Invalid email address",
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                        child: const Text("Reset password"),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await showAlertDialog(context);
                          final _status = await _authService.resetPassword(
                              email: _emailController.text.trim());
                          if (_status == AuthStatus.successful) {
                            navigator.pop();
                          } else {
                            final error =
                            AuthExceptionHandler.generateErrorMessage(
                                _status);
                            SnackBar(content: Text(error));
                          }
                        },
                      ),
                    ])));
  }
}