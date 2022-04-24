import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focus_spot_finder/services/dynamicLink.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/login.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/signup.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/initial_screen.dart';
import 'package:focus_spot_finder/screens/preAppLoad/splash_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  DynamicLinkService().handleInitialDeepLink();



  runApp(ProviderScope(child: FocusSpotFinder()));
}

class FocusSpotFinder extends StatelessWidget {
  final initialLink;
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

   const FocusSpotFinder({  this.initialLink}) ;

  @override
  Widget build(BuildContext context) {

      if (initialLink != null) {
        final Uri deepLink = initialLink.link;
        print(deepLink);
        print('deepLink deepLink deepLink');
      }else{
        print('deepLink else');

      }

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
