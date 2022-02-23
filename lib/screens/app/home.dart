import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/admin/issues_list.dart';
import 'package:focus_spot_finder/screens/app/widget/home_body.dart';

class Home extends HookWidget {
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
              icon: Image.asset('assets/chatbot.png',
                  fit: BoxFit.fitHeight, height: 40),
              tooltip: 'Chatbot',
              onPressed: () {
                //later
                Navigator.push(context, MaterialPageRoute(builder: (context) => issuesList()));
              },
            ),
          ),
        ],

      ),
      body: HomeBody(),
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
