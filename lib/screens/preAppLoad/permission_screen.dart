import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/app/setUp/app_page.dart';
import 'package:focus_spot_finder/screens/preAppLoad/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';

class PermissionScreen extends StatefulWidget {

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}


class _PermissionScreenState extends State<PermissionScreen> {

  bool isAdmin = false;


  @override
  void initState() {
    checkIfAdmin();

    super.initState();

  }

  Future<void> checkIfAdmin() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Admin').get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for (int x = 0; x < allData.length; x++) {
      var noteInfo = querySnapshot.docs[x].data() as Map<String, dynamic>;
      if (noteInfo["Email"] == FirebaseAuth.instance.currentUser.email) {
        isAdmin = true;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.red,
              size: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "The application needs to access your location, to be able to list workspaces around you",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(), primary: Colors.cyan.shade100),
                onPressed: () async {
                  // await OpenAppSettings.openAppSettings();
                  Logger().i(await Permission.locationWhenInUse.status);
                  if (await Permission.locationWhenInUse
                      .request()
                      .then((value) => value.isGranted)) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SplashScreen()));
                  } else {
                    Logger().i("opening setting");
                    openAppSettings();
                  }
                },
                child: Text('Allow Permission')
            ),
            TextButton(
                child: Text('Not Now',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    )),
                onPressed: () {
                  if(isAdmin){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminAppPage()));
                  }else{
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppPage()));
                  }

                }
            ),
          ],
        ),
      ),
    );
  }
}
