import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/splash_screen.dart';
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
                "We need Location permission inorder to make app working",
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(), primary: Colors.green.shade300),
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
                child: Text('Allow Permission'))
          ],
        ),
      ),
    );
  }
}
