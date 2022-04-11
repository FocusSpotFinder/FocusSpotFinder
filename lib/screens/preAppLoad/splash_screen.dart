import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/providers/places_provider.dart';
import 'package:focus_spot_finder/providers/places_state.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/initial_screen.dart';
import 'package:focus_spot_finder/screens/app/setUp/app_page.dart';
import 'package:focus_spot_finder/screens/preAppLoad/permission_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus_spot_finder/screens/preAppLoad/dynamicLink.dart';
import '../../models/place.dart';
import '../app/home/place_info.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({Key key});

  @override
  Widget build(BuildContext context, ref) {
    bool isAdmin = false;

    useEffect(() {
      DynamicLinkService().handleBackGroundDynamicLinks();
      //if the user is logged in
      //check location permission
      print('if permitted');
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

    ref.listen<PlacesState>(placesProvider, (p, c) async {
      if (c.currentPosition != null && !c.loading) {

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Admin').get();
        final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
        for (int x = 0; x < allData.length; x++) {
          var noteInfo = querySnapshot.docs[x].data() as Map<String, dynamic>;
          if (noteInfo["Email"] == FirebaseAuth.instance.currentUser.email) {
            log("Admin: "+noteInfo["Email"]);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminAppPage()));
            isAdmin = true;
            break;
          }
        }
        if (!isAdmin) {

          SharedPreferences prefs=await SharedPreferences.getInstance();
          if(prefs.getString('dLink') != null){
            String dLink=prefs.getString('dLink');
            print('dLink');
            print(dLink);
             Place place = await Place.getPlaceInfo(dLink).whenComplete(() =>
                prefs.remove('dLink'));

           Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => PlaceInfo(
              place: place,
              isFav: false,
              geo: place.geometry,
                )   ));
          }else
          
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppPage()));
        }
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
