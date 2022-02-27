import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/providers/places_provider.dart';
import 'package:focus_spot_finder/providers/places_state.dart';
import 'package:focus_spot_finder/screens/admin/admin_app_page.dart';
import 'package:focus_spot_finder/screens/permission_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:focus_spot_finder/screens/auth/initial_screen.dart';

class AdminSplashScreen extends HookConsumerWidget {
  const AdminSplashScreen({Key key});

  @override
  Widget build(BuildContext context, ref) {
    useEffect(() {
      //if the user is logged in
      //check location permission
      //if permitted
      if (FirebaseAuth.instance.currentUser != null) {
        Permission.locationWhenInUse.request().then((value) {
          Logger().i(value);
          if (value.isGranted) {
            ref.read(placesProvider.notifier).init(context);
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PermissionScreen()));
          }
        });
      } else {
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => InitialScreen()));
        });
      }

      return () {};
    }, []);

    ref.listen<PlacesState>(placesProvider, (p, c) {
      if (c.currentPosition != null && !c.loading) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminAppPage()));
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Admin',
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context).textTheme.headline1,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo.shade900,
                ),
              ),
            ),
            Image.asset('assets/logo.png', fit: BoxFit.fitHeight, height: 100),
            SizedBox(
              height: 20,
            ),
            SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ))
          ],
        ),
      ),
    );
  }
}
