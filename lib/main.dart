import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focus_spot_finder/screens/auth/login.dart';
import 'package:focus_spot_finder/screens/auth/signup.dart';
import 'package:focus_spot_finder/screens/auth/initial_screen.dart';
import 'package:focus_spot_finder/screens/splash_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: FocusSpotFinder()));
}

class FocusSpotFinder extends StatelessWidget {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Spot Finder',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: SplashScreen(),
      routes: {
        'signup': (context) => Signup(),
        'login': (context) => Login(),
        'initial_screen': (context) => InitialScreen(),
      },
    );
  }
}
