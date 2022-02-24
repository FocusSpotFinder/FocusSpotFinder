import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/addPlace/add_place_location_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:focus_spot_finder/screens/app/app_page.dart';
import 'package:focus_spot_finder/screens/app/widget/bottom_nav.dart';

class AddPlace extends StatefulWidget {
  @override
  State<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  final _formKey = GlobalKey<FormState>();
  final currentUser = UserModel();
  final nameEditingController = new TextEditingController();
  List<String> types = [];
  final typesEditingController = new TextEditingController();
  List<String> _types = [
    'Cafe', 'Library', 'Book Store', 'Park'
  ];
  List<String> userChecked = [];
  String documentId;

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter place name");
        }
        return null;
      },
      onSaved: (value) {
        nameEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.label),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final typesField = TextFormField(
      autofocus: false,
      controller: typesEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter place type");
        }
        return null;
      },
      onSaved: (value) {
        typesEditingController.text = value;
      },
      onTap: () {
        alertServices();
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dashboard_outlined),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Types",
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
          if (_formKey.currentState.validate()) {
            AlertDialogAddPlace(context, () {
              postPlaceDateToFirestoreBasics(
                  nameEditingController.text, userChecked, context);
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
                    SizedBox(height: height * .3),
                    //the title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Add Place',
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    //open a form and call the fields that was created up
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          nameField,
                          SizedBox(
                            height: 30,
                          ),
                          typesField,
                          SizedBox(
                            height: 18,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          nextButton,
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
      ),
      // bottomNavigationBar: BottomNav(
      //   onChange: (a) {
      //     Navigator.of(context).pushAndRemoveUntil(
      //         MaterialPageRoute(
      //             builder: (c) => AppPage(
      //                   initialPage: a,
      //                 )),
      //         (route) => false);
      //   },
      // ),
    );
  }

  void postPlaceDateToFirestoreBasics(
      String name, List<String> types, context) async {
    var collection = FirebaseFirestore.instance.collection('newPlace');
    var docRef = await collection.add({"Name": "$name", "Types": "$types"});
    var documentId = docRef.id;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPlacelocationPicker(docId: documentId)));
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

  alertServices() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Place Type",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 250.0, // Change as per your requirement
                      width: 300.0,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _types.length,
                          itemBuilder: (context, i) {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Center(
                                child: ListTile(
                                    title: Text(_types[i],
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    trailing: Checkbox(
                                      value: userChecked.contains(_types[i]),
                                      onChanged: (val) {
                                        setState(() {});
                                        _onSelected(val, _types[i]);
                                      },
                                    )),
                              );
                            });
                          }),
                    )
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                    child: Text("Close"),
                    onPressed: () {
                      typesEditingController.text = userChecked.join(", ");
                      Navigator.pop(context);
                    })
              ],
            );
          },
        );
      },
    );
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
