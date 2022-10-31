import 'package:flutter/material.dart';
//import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pickeep/sign_screens/sign_with_email_page.dart';
import 'package:provider/provider.dart';

import '../firebase_authentication/firebase_authentication_notifier.dart';
import '../firebase_authentication/firebase_google_authentication.dart';
import '../main.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool circular = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black,),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Pickeep",
              style: TextStyle(
                fontSize: 35,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Image(image: AssetImage('assets/ic_launcher_adaptive_fore_big.png'), ),


            const SizedBox(
              height: 40,
            ),
            colorButton("Sign In"),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Or",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            buttonItem(
                "assets/google.png", "Sign in with Google", 25, () async {final firebaseAuthenticationNotifier =
            Provider.of<FirebaseAuthenticationNotifier>(context,
                listen: false);
            firebaseAuthenticationNotifier.setFirebaseAuthentication(
                FirebaseGoogleAuthentication.instance());
            try
            {
              final result =
                  await firebaseAuthenticationNotifier.signIn();
            } catch (e) {
              // TODO:
            }
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Pickeep()),
                    (route) => false);}),
            const SizedBox(
              height: 10,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "If you don't have an Account ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (context) =>
                          SignWithEmailScreen(is_registered_user: false))),
                  child: const Text(
                    " Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }

  Widget buttonItem(
      String imagePath, String buttonName, double size, Function() onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          elevation: 8,
          color: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                width: 1,
                color: Colors.grey,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: size,
                width: size,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                buttonName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget textItem(
  //     String name, TextEditingController controller, bool obsecureText) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width - 70,
  //     height: 55,
  //     child: TextFormField(
  //       controller: controller,
  //       obscureText: obsecureText,
  //       style: const TextStyle(
  //         fontSize: 17,
  //         color: Colors.white,
  //       ),
  //       decoration: InputDecoration(
  //         labelText: name,
  //         labelStyle: const TextStyle(
  //           fontSize: 17,
  //           color: Colors.white,
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: const BorderSide(
  //             width: 1.5,
  //             color: Colors.amber,
  //           ),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(15),
  //           borderSide: const BorderSide(
  //             width: 1,
  //             color: Colors.grey,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget colorButton(String name) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (context) =>
              SignWithEmailScreen(is_registered_user: true))),
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [
            Color(0x9B277A4B),
            Color(0xFF277A4B),
            Color(0x9B277A4B),
          ]),
        ),
        child: Center(
          child: circular
              ? const CircularProgressIndicator()
              : Text(name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              )),
        ),
      ),
    );
  }
}