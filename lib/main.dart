import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FutureBuilder(
      future: initializeApp(),
      builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Pickeep();
        } else {
          return const LoadingScreen();
        }
      },
    ),
  );
}

Future<FirebaseApp> initializeApp() async {
  return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
}

class Pickeep extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => FirebaseAuthenticationNotifier(),
        child: Consumer<FirebaseAuthenticationNotifier>(
          builder: (context, firebaseAuthenticationNotifier, _) =>
              const MaterialApp(title: 'Pickeep', home: PickeepScreen()),
        ));
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        CircularProgressIndicator(),
      ],
    ));
  }
}

class PickeepScreen extends StatefulWidget {
  const PickeepScreen({Key? key}) : super(key: key);

  @override
  State<PickeepScreen> createState() => _PickeepScreenState();
}

class _PickeepScreenState extends State<PickeepScreen> {
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeApp(
          Provider.of<FirebaseAuthenticationNotifier>(context, listen: false)),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        } else if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.requireData;
        } else {
          return const LoadingScreen();
        }
      },
    );
  }

  Future<Widget> initializeApp(
      FirebaseAuthenticationNotifier firebaseAuthenticationNotifier) async {
    late Widget startScreen;

    if (FirebaseAuth.instance.currentUser == null) {
      startScreen = SignHomeScreen();
    } else {
      final currentUser = FirebaseAuth.instance.currentUser!;

      // TODO: load user data and change startScreen to home screen
      startScreen = SignHomeScreen();
    }

    return ChangeNotifierProvider.value(
        value: firebaseAuthenticationNotifier, child: startScreen);
  }
}
