import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/app/widget/home_body.dart';
import 'package:focus_spot_finder/screens/add_place.dart';

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
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: HomeBody(),
    );
  }

  //the main pop up menu
  Widget myPopMenu(BuildContext context, ValueNotifier<bool> isClicked) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white60,
      ),
      child: PopupMenuButton(
          offset: const Offset(-35, -100),
          icon: Image.asset('assets/logo.png', fit: BoxFit.cover, height: 40),
          onCanceled: () {
            isClicked.value = false;
          },
          onSelected: (value) {
            isClicked.value = false;

            if (value == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPlace()),
              );
            }

            print('pop up clicked');
          },
          itemBuilder: (context) {
            isClicked.value = false;
            return [
              PopupMenuItem(
                child: Center(
                  child: Text(
                    'Add Place',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                value: 0,
              ),
            ];
          }),
    );
  }
}

//shows alert if the user clicked on redierct to google map for navigation
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
    //title: Text(""),
    content: Text("Would you like to open Google Maps?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

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
