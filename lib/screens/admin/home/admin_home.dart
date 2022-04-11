import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/screens/admin/home/admin_home_body.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHome extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade100,
        toolbarHeight: 55,
        leading: SizedBox(width: 10),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Image.asset('assets/firebase.png',
                  fit: BoxFit.fitHeight, height: 32),
              tooltip: 'Firebase',
              onPressed: () {
                launchFirebase();
              },
            ),
          ),
        ],
      ),
      body: AdminHomeBody(),
    );
  }
}

//shows alert if the user clicked on redirect to google map for navigation
alertDialogGoogleNav(BuildContext context, onYes) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget continueButton = TextButton(child: Text("Continue"), onPressed: onYes);
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text("Would you like to open Google Maps?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

//to format the types in the listTiles
List<Text> typeFormat(List list) {
  List<Text> T = [];

  for (int i = 0; i < list.length && i < 2; i++) {
    if (list[i] != null) {
      if (i == 0) {
        T.add(Text(list[i].replaceAll('_', ' ').toString()));
      } else {
        T.add(Text(' \u00b7 ' + list[i].replaceAll('_', ' ').toString()));
      }
    }
  }
  return T;
}
Future<void> launchFirebase() async {
  String url = "https://firebase.google.com/?gclid=Cj0KCQiAmeKQBhDvARIsAHJ7mF6OmPIeu2W7gn63okFHkH8LhJvzQ7fQhWAUKbBA49A0IutQzYCMBEgaArhQEALw_wcB&gclsrc=aw.ds";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Fluttertoast.showToast(
      msg: "Could not open this website",
      toastLength: Toast.LENGTH_LONG,
    );
    throw 'Could not open this website';
  }
}
