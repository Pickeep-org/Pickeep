import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firebase_authentication/abstract_firebase_authentication.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/home_screen.dart';
import 'package:pickeep/sign_screens/sign_home_page.dart';
import 'package:pickeep/add_item_screen.dart';
import 'package:pickeep/item_screen.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

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
      child: MaterialApp(
          title: 'Pickeep',
          theme: FlexThemeData.light(
            fontFamily: GoogleFonts.beVietnamPro().fontFamily,
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            blendLevel: 20,
            appBarOpacity: 0.95,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 20,
              blendOnColors: false,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
          ),
          darkTheme: FlexThemeData.dark(
            fontFamily: GoogleFonts.beVietnamPro().fontFamily,
            scheme: FlexScheme.blue,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            blendLevel: 15,
            appBarStyle: FlexAppBarStyle.background,
            appBarOpacity: 0.90,
            subThemesData: const FlexSubThemesData(
              blendOnLevel: 30,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
          ),
          home: const PickeepScreen()),
    );
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
      startScreen = const HomeScreen();
      firebaseAuthenticationNotifier.setFirebaseAuthentication(
          AFirebaseAuthentication.fromProviderId(FirebaseAuth
              .instance.currentUser!.providerData.first.providerId));
    }

    await Filters().loadFilters();

    return ChangeNotifierProvider.value(
        value: firebaseAuthenticationNotifier, child: startScreen);
  }
}
