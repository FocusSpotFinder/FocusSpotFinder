import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/admin/home/admin_place_info.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/admin/issue/edit_place.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_bottom_nav.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_center_bottom_button.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class reportInfo extends StatefulWidget {
  final void Function() onBackPress;
  final Issue issue;
  const reportInfo({this.issue, Key key, @required this.onBackPress}) : super(key: key);

  @override
  State<reportInfo> createState() => _reportInfoState();
}

class _reportInfoState extends State<reportInfo> {
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
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                  children: [
                                    IconButton(
                                      icon: Image.asset('assets/logo.png'),
                                      iconSize: 80,
                                      onPressed: () async {

                                        Place place = await Place.getPlaceInfo(
                                            widget.issue.placeId);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AdminPlaceInfo(
                                              place: place,
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
                        SizedBox(
                          height: 25,
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
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),

                              Text(widget.issue.status,
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
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("Place ID",
                                        style: GoogleFonts.lato(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                    IconButton(
                                        icon: new Icon(Icons.copy,
                                            color: Colors.black, size: 30),
                                        tooltip: 'Copy',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: widget.issue.placeId));
                                          Fluttertoast.showToast(
                                            msg: "Place ID copied to clipboard",
                                            toastLength: Toast.LENGTH_LONG,
                                          );
                                        }
                                    ),
                                  ]
                              ),

                              Text(widget.issue.placeId,
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
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text("User ID",
                                        style: GoogleFonts.lato(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                                    IconButton(
                                        icon: new Icon(Icons.copy,
                                            color: Colors.black, size: 30),
                                        tooltip: 'Copy',
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: widget.issue.userId));
                                          Fluttertoast.showToast(
                                            msg: "User ID copied to clipboard",
                                            toastLength: Toast.LENGTH_LONG,
                                          );
                                        }
                                    ),
                                  ]
                              ),


                              Text(widget.issue.userId,
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
                        SizedBox(
                          height: 15,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:[
                              Text("Message",
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),

                              Text(widget.issue.message,
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blueGrey.shade700,
                                  )),
                            ]
                        ),

                        (widget.issue.status == "Resolved")?
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:[
                              SizedBox(
                                height: 15,
                              ),
                              Text("Resolve date",
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),

                              Text(widget.issue.resolveTime,
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blueGrey.shade700,
                                  )),
                            ]
                        ):Row(),

                        (widget.issue.status == "Resolved" )?
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:[
                              SizedBox(
                                height: 15,
                              ),
                              Text("Resolve by",
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),

                              Text(widget.issue.resolvedBy,
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.blueGrey.shade700,
                                  )),
                            ]
                        ):Row(),

                        SizedBox(
                          height: 25,
                        ),



                        (widget.issue.status != "Resolved")?
                        Row(
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
                                            //google place, black list
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
                            ]): Row(),
                        SizedBox(
                          height: 25,
                        ),
                        (widget.issue.status != "Resolved")?
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
                                          "Resolved by": "${loggedInUser.email}"
                                        });
                                        widget.issue.status = "Resolved";
                                        Fluttertoast.showToast(
                                          msg: "Issue resolved successfully",
                                          toastLength: Toast.LENGTH_LONG,
                                        );
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
                          height: 35,
                        ),
                      ]),
                ),
              )
            ]





        ),

        floatingActionButton: AdminCenterBottomButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AdminBottomNav(
          onChange: (a) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (c) => AdminAppPage(initialPage: a,)),
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
    var collection = FirebaseFirestore.instance.collection('googlePlaceBlackList');
    var docRef = await collection.add({"PlaceId": "$placeId"});
    var documentId = docRef.id;
  }

  deleteFirebasePlace (placeId) async {
    FirebaseFirestore.instance.collection('newPlace').doc(placeId).delete();
  }

}
