import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/app/setUp/app_page.dart';
import 'package:focus_spot_finder/screens/preAppLoad/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}


class _PermissionScreenState extends State<PermissionScreen> {

  bool isAdmin = false;


  @override
  void initState() {
    //first check if the user is admin or not
    checkIfAdmin();

    super.initState();

  }

  Future<void> checkIfAdmin() async {
    //gets snapshot of the admins collection and maps it to accessible data
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Admin').get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    //loop over the admin collection dara
    for (int x = 0; x < allData.length; x++) {
      var noteInfo = querySnapshot.docs[x].data() as Map<String, dynamic>;
      //if the email in admin collection equals the current user email, then the user is admin
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
        //column that has an icon and explain for the user what is the problem
        //which is that we cant access the location so the user can use the app properly
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
            //Allow permission button the user can click to open the settings and allow location permission
            ElevatedButton(
                style: ElevatedButton.styleFrom(shape: StadiumBorder(), primary: Colors.cyan.shade100),
                onPressed: () async {
                  Logger().i(await Permission.locationWhenInUse.status);
                  if (await Permission.locationWhenInUse
                      .request()
                      .then((value) => value.isGranted)) {
                    //when the user allow permission navigate to splash screen to redirect the user
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SplashScreen()));
                  } else {
                    //open app settings so the user can enable permissions
                    Logger().i("opening setting");
                    openAppSettings();
                  }
                },
                child: Text('Allow Permission')
            ),
            //Not Now button, so the user can skip the permissions and open the app, but the map and places will not be listed
           //because they require user location to list the places
            TextButton(
                child: Text('Not Now',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    )),
                onPressed: () {
                  //if admin redirect to admin app page, otherwise to user app page
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
