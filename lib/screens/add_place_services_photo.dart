import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/add_place_working_hours.dart';
import 'package:focus_spot_finder/screens/controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

class AddPlaceServicesPhoto extends StatefulWidget {
  final String docId;
  AddPlaceServicesPhoto({this.docId});

  @override
  State<AddPlaceServicesPhoto> createState() => _AddPlaceServicesPhotoState();
}

class _AddPlaceServicesPhotoState extends State<AddPlaceServicesPhoto> {
  var myController = Get.put(MyController());
  var photo;

  List<String> _availableServices = [
    "WiFi",
    "Meetings Room",
    "Isolated Capsule Room",
    "Closed Room",
    "Outdoor"
  ];
  List<String> userChecked = [];
  String checked = "";

  @override
  void initState() {
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1)).then((value) => setState(() {}));

    final addPlacePhotoButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.white,
      child: MaterialButton(
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          onPressed: () {
            myController.displayBottomSheet(context);
            setState(() {});
          },
          child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // use whichever suits your need

              children: [
                Icon(Icons.local_see, size: 30, color: Colors.indigo.shade900),
                Text(
                  ' Add photo',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.indigo.shade900,
                      fontWeight: FontWeight.bold),
                ),
              ])),
    );

    final nextButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {
          AlertDialogAddPlaceServicesPhoto(context, () async {
            if (myController.f1.value != null &&
                myController.f1.value.path.isNotEmpty) {
              photo = await uploadImageToStorage(
                  myController.f1.value, widget.docId);
            }

            postPlaceDateToFirestoreServicesPhoto(photo, userChecked, context);

            myController.f1 = File('').obs;

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        addPlaceworkingHours(docId: widget.docId)));
          });
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
                      text: 'Additional Information',
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
                      "If you know any of the following additional place information, please add them, or leave it empty",
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )),

                  SizedBox(height: 30),

                  SizedBox(height: 30),

                  Text("Available Services",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo.shade900,
                      )),
                  SizedBox(height: 10),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        // height: 300, // constrain height
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: _availableServices.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                  title: Text(_availableServices[i],
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      )),
                                  trailing: Checkbox(
                                    value: userChecked
                                        .contains(_availableServices[i]),
                                    onChanged: (val) {
                                      _onSelected(val, _availableServices[i]);
                                    },
                                  )
                                  //you can use checkboxlistTile too
                                  );
                            }),
                      )
                    ],
                  ),
                  SizedBox(height: 30),

                  Text("Photo",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.indigo.shade900,
                      )),
                  SizedBox(height: 10),

                  Container(
                    // color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 50,
                                height: 55,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: FileImage(myController.f1.value),
                                  ),
                                ),
                              ),
                              SizedBox(width: 30),
                              SizedBox(
                                  width: 160.0,
                                  height: 70.0,
                                  child: addPlacePhotoButton),
                            ]),
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
                              postPlaceDateToFirestoreServicesPhoto(
                                  photo, userChecked, context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          addPlaceworkingHours(
                                              docId: widget.docId)));
                            }),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void postPlaceDateToFirestoreServicesPhoto(
      photo, List<String> services, context) async {
    var doc =
        FirebaseFirestore.instance.collection('newPlace').doc(widget.docId);
    if (photo != null) {
      var docRef = await doc.update({"Photo": "[$photo]"});
      photo = null;
    } else {
      var docRef = await doc.update({"Photo": ""});
    }

    var collection =
        FirebaseFirestore.instance.collection('newPlace').doc(widget.docId);
    var docReff = await collection.update({"Available services": "$services"});
  }

  AlertDialogAddPlaceServicesPhoto(BuildContext context, onYes) {
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

  Future<String> uploadImageToStorage(File imageFile, String docId) async {
    var url;
    var _data = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("newPlaceImages")
          .child(widget.docId)
          .child("PlaceImages")
          .child(_data);
      UploadTask storageUploadTask = storageReference.putFile(imageFile);
      url = await (await storageUploadTask.whenComplete(() => true))
          .ref
          .getDownloadURL();
      return url;
    } catch (e) {
      print(e);
    }

    return url;
  }

  void _onSelected(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userChecked.add(dataName);
      });
    } else {
      setState(() {
        userChecked.remove(dataName);
      });
    }
  }
}
