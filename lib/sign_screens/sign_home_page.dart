// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/firebase_authentication/firebase_google_authentication.dart';
import 'package:pickeep/home_screen.dart';
import 'package:pickeep/sign_screens/sign_with_email_page.dart';
import 'package:provider/provider.dart';

class SignHomeScreen extends StatelessWidget {
  final TextEditingController _emailTextEditingController;

  SignHomeScreen({Key? key})
      : _emailTextEditingController = TextEditingController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text(
        'PicKeep',
      )),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Login or sign up for free',
            ),
          ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (context) =>
                  SignWithEmailScreen(is_registered_user: true))), child: Text('Sign in with Email')),
            Row(children: <Widget>[
              Expanded(
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Text("OR"),
              Expanded(
                child: Divider(
                  color: Colors.black,
                ),
              ),
            ]),
            ElevatedButton(onPressed: () async {
              final firebaseAuthenticationNotifier =
              Provider.of<FirebaseAuthenticationNotifier>(context,
                  listen: false);
              firebaseAuthenticationNotifier.setFirebaseAuthentication(
                  FirebaseGoogleAuthentication.instance());
              try
              {
                final result =
                await firebaseAuthenticationNotifier.signIn();
                final uid = result.user?.uid;
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            HomeScreen()),
                        (route) => false);
              } catch (e) {
                // TODO:
              }
            }, child: Text('Sign in with Google')),
            ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (context) =>
                    SignWithEmailScreen(is_registered_user: false))), child: Text('Sign up with email')),
          ],
        ),
      ),
    );
  }
}
