import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focus_spot_finder/services/dynamicLink.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/login.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/signup.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/initial_screen.dart';
import 'package:focus_spot_finder/screens/preAppLoad/splash_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //to interact with flutter engine and ensure the binding is initialized
  await Firebase.initializeApp(); //to initialize firebase
  DynamicLinkService().handleInitialDeepLink(); //check if there is a link sent when the app is opened we want to handle it
  runApp(ProviderScope(child: FocusSpotFinder())); //run the application
}

class FocusSpotFinder extends StatelessWidget {
  final initialLink; //to handle the share link
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); //used to navigate within the app

   const FocusSpotFinder({  this.initialLink}) ;

  @override
  Widget build(BuildContext context) {

      if (initialLink != null) {
        final Uri deepLink = initialLink.link;
        print(deepLink);
        print('deepLink');
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
      //always open splashScreen first
      home: SplashScreen(),
      //the routes the application will follow when starts, depends on the user login state
      routes: {
        'signup': (context) => Signup(),
        'login': (context) => Login(),
        'initial_screen': (context) => InitialScreen(),
      },
    );
  }
}
