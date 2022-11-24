import 'package:flutter/material.dart';
import 'package:pickeep/firebase_authentication/firebase_email_authentication.dart';

// String extension for email format.
extension EmailValidator on String {
  bool isValid() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

// Handles the password reset sequence when asked by the user. this class invoke
// the reset password method in the Firebase Email Authentication.
class ResetPassScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _authService = FirebaseEmailAuthentication.instance();

  ResetPassScreen({Key? key}) : super(key: key);
  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: const Text("Ok"),
      onPressed: () {
        Navigator.of(context).pop(true);
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Hello"),
      content: const Text("Please check your mailbox for further instructions"),
      actions: [
        okButton,
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
  Widget build(BuildContext context) {
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
                          await showAlertDialog(context);
                          final status = await _authService.resetPassword(
                              email: _emailController.text.trim());
                          if (status == AuthStatus.successful) {
                            Navigator.of(context).pop();
                          } else {
                            final error =
                            AuthExceptionHandler.generateErrorMessage(
                                status);
                            SnackBar(content: Text(error));
                          }
                        },
                      ),
                    ])));
  }
}