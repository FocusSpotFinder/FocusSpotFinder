import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/admin/edit_place.dart';
import 'package:focus_spot_finder/screens/app/app_page.dart';
import 'package:focus_spot_finder/screens/app/widget/bottom_nav.dart';
import 'package:focus_spot_finder/screens/app/widget/center_bottom_button.dart';
import 'package:focus_spot_finder/screens/place_info.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class issueInfo extends StatefulWidget {
  final void Function() onBackPress;
  final Issue issue;
  const issueInfo({this.issue, Key key, @required this.onBackPress}) : super(key: key);

  @override
  State<issueInfo> createState() => _issueInfoState();
}

class _issueInfoState extends State<issueInfo> {
  bool isClicked = false;
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPress();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan.shade100,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 30),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          toolbarHeight: 55,
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
        body:  Stack(
            children: <Widget> [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                              children:[
                                Text("Type",
                                    style: GoogleFonts.lato(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )),

                                Text(widget.issue.type,
                                    style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.blueGrey.shade700,
                                    )),
                              ]
                            ),

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  Text("Status",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  Text(widget.issue.status,
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey.shade700,
                                      )),
                                ]
                            ),

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  Text("Place ID",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  Text(widget.issue.placeId,
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey.shade700,
                                      )),
                                ]
                            ),

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  Text("User ID",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  Text(widget.issue.userId,
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey.shade700,
                                      )),
                                ]
                            ),

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  Text("Report date",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  Text(widget.issue.reportTime,
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey.shade700,
                                      )),
                                ]
                            ),
                            (widget.issue.status == "Resolved" || widget.issue.status == "Approved"|| widget.issue.status == "Declined")?
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text("Resolve date",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  Text(widget.issue.resolveTime,
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey.shade700,
                                      )),
                                ]
                            ):Row(),

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  Text("Message",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  Text(widget.issue.message,
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey.shade700,
                                      )),
                                ]
                            ),

                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                      children: [
                                        IconButton(
                                          icon: Image.asset('assets/logo.png'),
                                          iconSize: 60,
                                          onPressed: () async {

                                            Place place = await Place.getPlaceInfo(
                                                widget.issue.placeId);
                                            bool isFav = await Place.checkIfFav(
                                                widget.issue.placeId);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PlaceInfo(
                                                  place: place,
                                                  isFav: isFav,
                                                  geo: place.geometry,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        Text("Place",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            )),
                                      ]),

                                ]
                            ),

                            (widget.issue.type == "New place added")?
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      children: [
                                        IconButton(
                                          icon: Image.asset('assets/check.png'),
                                          iconSize: 60,
                                          onPressed: () async {
                                            var collection = FirebaseFirestore.instance.collection('newPlace').doc(widget.issue.placeId);
                                            var docRef = await collection.update({
                                              "Status": "Approved",
                                            });

                                            DateTime resolveTime = DateTime.now();

                                            var collection2 = FirebaseFirestore.instance.collection('Reports').doc(widget.issue.reportId);
                                            var docRef2 = await collection2.update({
                                              "Status": "Approved",
                                              "Resolve time": "$resolveTime",
                                            });

                                            Navigator.of(context).pop();

                                          },


                                        ),

                                        Text("Approve",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            )),
                                      ]),
                                  Column(
                                      children: [
                                        IconButton(
                                          icon: Image.asset('assets/x.png'),
                                          iconSize: 60,
                                          onPressed: () async {
                                            var collection = FirebaseFirestore.instance.collection('newPlace').doc(widget.issue.placeId);
                                            var docRef = await collection.update({
                                              "Status": "Not approved",
                                            });

                                            DateTime resolveTime = DateTime.now();

                                            var collection2 = FirebaseFirestore.instance.collection('Reports').doc(widget.issue.reportId);
                                            var docRef2 = await collection2.update({
                                              "Status": "Declined",
                                              "Resolve time": "$resolveTime",
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),

                                        Text("Decline",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            )),
                                      ]),
                                ])
                                : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      children: [
                                        IconButton(
                                          icon: Image.asset('assets/edit.png'),
                                          iconSize: 60,
                                          onPressed: () async {
                                            Place place = await Place.getPlaceInfo(
                                                widget.issue.placeId);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => editPlace(
                                                  place: place,
                                                ),
                                              ),
                                            );

                                          },
                                        ),

                                        Text("Edit Place",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            )),
                                      ]),

                                  Column(
                                      children: [
                                        IconButton(
                                          icon: Image.asset('assets/delete.png'),
                                          iconSize: 60,
                                          onPressed: () async {
                                            AlertDialogDelete(context, ()  {
                                              Navigator.of(context).pop();
                                              //delete place
                                              if(widget.issue.placeId.length == 27){
                                                //google place
                                                //black list
                                                deleteGooglePlace(widget.issue.placeId);

                                              }else{
                                                //new place
                                              deleteFirebasePlace(widget.issue.placeId);

                                              }
                                              Fluttertoast.showToast(
                                                msg: "Place deleted successfully",
                                                toastLength: Toast.LENGTH_LONG,
                                              );
                                            });
                                          },
                                        ),

                                        Text("Delete Place",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            )),
                                      ]),

                                ]),


                            (widget.issue.type != "New place added")?
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                      children: [
                                        IconButton(
                                          icon: Image.asset('assets/check.png'),
                                          iconSize: 60,
                                          onPressed: () async {
                                            DateTime resolveTime = DateTime.now();

                                            var collection2 = FirebaseFirestore.instance.collection('Reports').doc(widget.issue.reportId);
                                            var docRef2 = await collection2.update({
                                              "Status": "Resolved",
                                              "Resolve time": "$resolveTime",
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),

                                        Text("Resolve Issue",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.lato(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            )),
                                      ]),

                                ]): Row(),
                          SizedBox(
                            height: 20,
                          ),
                          ]),
                  ),
              )
            ]





        ),

        floatingActionButton: CenterBottomButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNav(
          onChange: (a) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (c) => AppPage(initialPage: a,)),
                    (route) => false);
          },

        ),
      ),
    );
  }

  AlertDialogDelete(BuildContext context, onYes) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(child: Text("Yes"), onPressed: onYes);
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Are sure you want to delete this place?"),
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

  deleteGooglePlace (placeId) async {

  }

  deleteFirebasePlace (placeId) async {
     FirebaseFirestore.instance.collection('newPlace').doc(placeId).delete();
  }

}
