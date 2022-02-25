import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/app/app_page.dart';
import 'package:focus_spot_finder/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({Key key}) : super(key: key);

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
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => AppPage()));
                }
            ),
          ],
        ),
      ),
    );
  }
}
