import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/app/setUp/app_page.dart';
import 'package:google_fonts/google_fonts.dart';

class addPlaceSocial extends StatefulWidget {
  String docId;
  addPlaceSocial({this.docId});

  @override
  State<addPlaceSocial> createState() => _addPlaceSocialState();
}

class _addPlaceSocialState extends State<addPlaceSocial> {
  final _formKey = GlobalKey<FormState>();
  final currentUser = UserModel();
  User user = FirebaseAuth.instance.currentUser;
  bool isAdmin = false;

  final phoneNumberEditingController = new TextEditingController();
  final websiteEditingController = new TextEditingController();
  final twitterEditingController = new TextEditingController();
  final instagramEditingController = new TextEditingController();

  String documentId;

  @override
  void initState() {
    super.initState();

    checkIfAdmin();
  }



  @override
  Widget build(BuildContext context) {
    final phoneNumberField = TextFormField(
      autofocus: false,
      controller: phoneNumberEditingController,
      keyboardType: TextInputType.phone,
      validator: (value) {},
      onSaved: (value) {
        phoneNumberEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Phone Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final websiteField = TextFormField(
      autofocus: false,
      controller: websiteEditingController,
      validator: (value) {},
      onSaved: (value) {
        websiteEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon:
              Image.asset('assets/websiteGrey.jpg', height: 30, width: 30),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Website",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final twitterField = TextFormField(
      autofocus: false,
      controller: twitterEditingController,
      validator: (value) {},
      onSaved: (value) {
        twitterEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Image.asset('assets/twitter.png', height: 20, width: 20),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "@Twitter",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final instagramField = TextFormField(
      autofocus: false,
      controller: instagramEditingController,
      validator: (value) {},
      onSaved: (value) {
        instagramEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon:
              Image.asset('assets/instagram.png', width: 15, height: 15),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "@Instagram",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final nextButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {
          if (phoneNumberEditingController.text == "" &&
              websiteEditingController.text == "" &&
              twitterEditingController.text == "" &&
              instagramEditingController.text == "" ){
            Fluttertoast.showToast(
              msg: "Please insure that you have entered information, or skip",
              toastLength: Toast.LENGTH_LONG,
            );
          }else if (phoneNumberEditingController.text != null ||
              websiteEditingController.text != null ||
              twitterEditingController.text != null ||
              instagramEditingController.text != null ) {
            AlertDialogAddPlace(context, () {
              postPlaceDateToFirestoreSocial(
                  phoneNumberEditingController.text,
                  websiteEditingController.text,
                  twitterEditingController.text,
                  instagramEditingController.text,
                  context);
            });
          }
        },
        child: Text(
          'Add Place',
          style: TextStyle(
              fontSize: 20,
              color: Colors.indigo.shade900,
              fontWeight: FontWeight.bold),
        ),
      ),
    );

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          //to show the decoration on the background
          Positioned(
            top: -MediaQuery.of(context).size.height * .15,
            right: -MediaQuery.of(context).size.width * .4,
            child: Container(
                child: Transform.rotate(
              angle: -pi / 3.5,
              child: ClipPath(
                clipper: ClipPainter(),
                child: Container(
                  height: MediaQuery.of(context).size.height * .5,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.cyan.shade50,
                        Colors.cyan.shade400,
                      ],
                    ),
                  ),
                ),
              ),
            )),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  //the title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Place information',
                      style: GoogleFonts.lato(
                        textStyle: Theme.of(context).textTheme.headline1,
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Text(
                      "If you know the any of the following fields please fill them, or skip",
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )),

                  SizedBox(height: 50),
                  //open a form and call the fields that was created up
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        phoneNumberField,
                        SizedBox(
                          height: 30,
                        ),
                        websiteField,
                        SizedBox(
                          height: 30,
                        ),
                        twitterField,
                        SizedBox(
                          height: 30,
                        ),
                        instagramField,
                        SizedBox(
                          height: 30,
                        ),
                        nextButton,
                        TextButton(
                            child: Text('Skip',
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                )),
                            onPressed: () {
                              if(phoneNumberEditingController.text != "" ||
                                  websiteEditingController.text != "" ||
                                  twitterEditingController.text != "" ||
                                  instagramEditingController.text != "" ){
                                AlertDialogSkip(context, () {
                                  postPlaceDateToFirestoreSocial(
                                      phoneNumberEditingController.text,
                                      websiteEditingController.text,
                                      twitterEditingController.text,
                                      instagramEditingController.text,
                                      context);
                                  if(isAdmin){
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminAppPage()));
                                  }else{
                                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppPage()));
                                  }

                                });
                              }else{
                                postPlaceDateToFirestoreSocial(
                                    phoneNumberEditingController.text,
                                    websiteEditingController.text,
                                    twitterEditingController.text,
                                    instagramEditingController.text,
                                    context);
                                if(isAdmin){
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminAppPage()));
                                }else{
                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppPage()));
                                }
                              }

                            }),
                      ],
                    ),
                  ),
                  SizedBox(height: height * .055),
                ],
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 0,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                      child: Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.black, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void postPlaceDateToFirestoreSocial(String phone, String website,
      String twitter, String instagram, context) async {
    if(!isAdmin){
      var collection = FirebaseFirestore.instance.collection('newPlace').doc(widget.docId);
      var docRef = await collection.update({
        "Phone number": "$phone",
        "Website": "$website",
        "Twitter": "$twitter",
        "Instagram": "$instagram",
        "Status": "Waiting",
      });

      postPlaceDateToFirestoreReports(user.uid, widget.docId, "New place added", "New place added", context);
      AlertDialogPlaceAdded(context, ()  {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppPage()));

      });
    }else{
      var collection = FirebaseFirestore.instance.collection('newPlace').doc(widget.docId);
      var docRef = await collection.update({
        "Phone number": "$phone",
        "Website": "$website",
        "Twitter": "$twitter",
        "Instagram": "$instagram",
        "Status": "Approved",
      });

      AlertDialogPlaceAddedAdmin(context, ()  {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AdminAppPage()));

      });
    }



  }

  void postPlaceDateToFirestoreReports(String uid, String placeId, String type, String message, context) async {
    DateTime reportTime = DateTime.now();
    var collection = FirebaseFirestore.instance.collection('Reports');
    var docRef = await collection.add({
      "UserId": "$uid",
      "PlaceId": "$placeId",
      "Type":"$type",
      "Status":"Waiting",
      "Report time": "$reportTime",
      "Message":"$message",
      "Resolve time":""});

  }

  AlertDialogAddPlace(BuildContext context, onYes) {
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
      content: Text("Are sure of the entered place information?"),
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

  AlertDialogSkip(BuildContext context, onYes) {
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
      content: Text("Are sure you want to skip?"),
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

  AlertDialogPlaceAdded(BuildContext context, onYes) {
    // set up the buttons
    Widget continueButton = TextButton(child: Text("Close"), onPressed: onYes);
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Place added successfully!!\nWaiting for its approval\nThank you!"),
      actions: [
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

  AlertDialogPlaceAddedAdmin(BuildContext context, onYes) {
    // set up the buttons
    Widget continueButton = TextButton(child: Text("Close"), onPressed: onYes);
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Place added successfully!!\nThank you!"),
      actions: [
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

}
