import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:focus_spot_finder/screens/app/addPlace/add_place_services_photo.dart';

class AddPlaceRateReview extends StatefulWidget {
  final String docId;
  AddPlaceRateReview({this.docId});

  @override
  State<AddPlaceRateReview> createState() => _AddPlaceRateReviewState();
}

class _AddPlaceRateReviewState extends State<AddPlaceRateReview> {
  final reviewEditingController = new TextEditingController();
  double quietRate = 0;
  double crowdedRate = 0;
  double foodRate = 0;
  double techRate = 0;

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1)).then((value) => setState(() {}));
    final reviewField = TextFormField(
      autofocus: false,
      controller: reviewEditingController,
      onSaved: (value) {
        reviewEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      maxLines: 5,
      // when user presses enter it will adapt to it
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Review",
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

          if(quietRate==0 || crowdedRate==0 || foodRate==0 || techRate==0 || reviewEditingController.text=="" ){
            Fluttertoast.showToast(
              msg: "Please insure that all information are entered",
              toastLength: Toast.LENGTH_LONG,
            );
          }else {
            AlertDialogAddPlaceRateReview(context, () {
              postPlaceDateToFirestoreRateReview(
                  quietRate, crowdedRate, foodRate,
                  techRate, reviewEditingController.text, context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      AddPlaceServicesPhoto(docId: widget.docId)));
            });
          }
        },
        child: Text(
          'Next',
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
                      text: 'Rate and Review',
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
                      "Please rate the workspace based on the following criteria's, and add a review, or skip",
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )),

                  SizedBox(height: 30),

                  Text("Rating",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo.shade900,
                      )),
                  SizedBox(height: 10),

                  Column(children: [
                    Text("Quiet",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                          default:
                            return SizedBox.shrink();
                        }
                      },
                      onRatingUpdate: (rating) {
                        print(rating);
                        quietRate = rating;
                      },
                    ),
                  ]),

                  SizedBox(height: 10),

                  Column(children: [
                    Text("Crowded",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                          default:
                            return SizedBox.shrink();
                        }
                      },
                      onRatingUpdate: (rating) {
                        print(rating);
                        crowdedRate = rating;
                      },
                    ),
                  ]),
                  SizedBox(height: 10),

                  Column(children: [
                    Text("Food Quality",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                          default:
                            return SizedBox.shrink();
                        }
                      },
                      onRatingUpdate: (rating) {
                        print(rating);
                        foodRate = rating;
                      },
                    ),
                  ]),
                  SizedBox(height: 10),

                  Column(children: [
                    Text("Technical Facilities",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                          default:
                            return SizedBox.shrink();
                        }
                      },
                      onRatingUpdate: (rating) {
                        print(rating);
                        techRate = rating;
                      },
                    ),
                  ]),

                  SizedBox(height: 30),
                  Text("Review",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo.shade900,
                      )),
                  SizedBox(height: 10),

                  reviewField,

                  SizedBox(height: 30),
                  nextButton,
                  TextButton(
                      child: Text('Skip',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          )),
                      onPressed: () {
                        if(quietRate!=0 || crowdedRate!=0 || foodRate!=0 || techRate!=0 || reviewEditingController.text!="" ){
                          AlertDialogSkip(context, () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddPlaceServicesPhoto(
                                        docId: widget.docId)));
                          });
                        }else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddPlaceServicesPhoto(
                                      docId: widget.docId)));
                        }

                      }
                      ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void postPlaceDateToFirestoreRateReview(double quiet, double crowded,
      double food, double tech, String review, context) async {
    final _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    String uid = user.uid;
    String placeId = widget.docId;

    if (review != "") {
      var collection = FirebaseFirestore.instance.collection('Review').doc();
      var docReff = await collection
          .set({"Review": "$review", "User ID": "$uid", "PlaceId": "$placeId"});
    }

    if (quiet != 0 && crowded != 0 && food != 0 && tech != 0) {
      var collection2 = FirebaseFirestore.instance.collection('Rate').doc();
      var docReff2 = await collection2.set({
        "User ID": "$uid",
        "PlaceId": "$placeId",
        "Quiet": "$quiet",
        "Crowded": "$crowded",
        "Food quality": "$food",
        "Technical facilities": "$tech"
      });
    }
  }

  AlertDialogAddPlaceRateReview(BuildContext context, onYes) {
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


}
