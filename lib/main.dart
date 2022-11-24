import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pickeep/favorites.dart';
import 'package:pickeep/filters.dart';
import 'package:pickeep/firebase_authentication/abstract_firebase_authentication.dart';
import 'package:pickeep/firebase_authentication/firebase_authentication_notifier.dart';
import 'package:pickeep/home_screen.dart';
import 'package:pickeep/sign_screens/contact_info_screen.dart';
import 'current_user_info.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:pickeep/sign_screens/sign_in_screen.dart';

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
          return const Pickeep();
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
  const Pickeep({Key? key}) : super(key: key);

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => FirebaseAuthenticationNotifier()),
        StreamProvider(
          create: (context) => Connectivity().onConnectivityChanged,
          initialData: ConnectivityResult.none,
        ),
      ],
      child: MaterialApp(
          title: 'PicKeep',
          theme: FlexThemeData.light(
            fontFamily: GoogleFonts.beVietnamPro().fontFamily,
            scheme: FlexScheme.jungle,
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
            scheme: FlexScheme.jungle,
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
        Image(image: AssetImage('assets/ic_launcher_adaptive_fore.png')),
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
  Widget? lastRequireData;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityResult>(
      builder: (context, value, child) {
        if (value != ConnectivityResult.wifi &&
            value != ConnectivityResult.mobile &&
            value != ConnectivityResult.ethernet &&
            lastRequireData != null) {
          return lastRequireData!;
        }

        return FutureBuilder(
          future: initializeApp(Provider.of<FirebaseAuthenticationNotifier>(
              context,
              listen: false)),
          builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.hasError) {
              if (value != ConnectivityResult.wifi &&
                  value != ConnectivityResult.mobile &&
                  value != ConnectivityResult.ethernet) {
                return Scaffold(
                  body: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          FittedBox(
                            fit: BoxFit.fill,
                            child: Center(
                                heightFactor: 2,
                                widthFactor: 2,
                                child: Icon(Icons.signal_wifi_off_sharp)),
                          ),
                          Text('Please check your internet connection',
                              style: TextStyle(fontSize: 30),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr),
                        ],
                      )),
                );
              }

              return const LoadingScreen();
            } else if (snapshot.connectionState == ConnectionState.done) {
              lastRequireData = snapshot.requireData;
              return snapshot.requireData;
            } else {
              return const LoadingScreen();
            }
          },
        );
      },
    );
  }

  Future<Widget> initializeApp(
      FirebaseAuthenticationNotifier firebaseAuthenticationNotifier) async {
    late Widget startScreen;
    if (FirebaseAuth.instance.currentUser == null ||
        !FirebaseAuth.instance.currentUser!.emailVerified) {
      startScreen = const SignInPage(); //SignHomeScreen();
    } else {
      try {
        await CurrentUserInfo()
            .loadUser(FirebaseAuth.instance.currentUser!.uid);
        await Favorites().getFromDB(FirebaseAuth.instance.currentUser!.uid);
        startScreen = const HomeScreen();
      } catch (e) {
        startScreen = const ContactInfoScreen();
      }
      await Filters().loadFilters();
      firebaseAuthenticationNotifier.setFirebaseAuthentication(
          AFirebaseAuthentication.fromProviderId(FirebaseAuth
              .instance.currentUser!.providerData.first.providerId));
    }

    return ChangeNotifierProvider.value(
        value: firebaseAuthenticationNotifier, child: startScreen);
  }
}
