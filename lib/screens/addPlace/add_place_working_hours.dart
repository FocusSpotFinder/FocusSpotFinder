import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/screens/addPlace/add_place_social.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class addPlaceworkingHours extends StatefulWidget {
  String docId;
  addPlaceworkingHours({this.docId});

  @override
  State<addPlaceworkingHours> createState() => _addPlaceworkingHoursState();
}

class _addPlaceworkingHoursState extends State<addPlaceworkingHours> {
  final _formKey = GlobalKey<FormState>();
  final currentUser = UserModel();
  List<String> workingHours;
  String wk = "";

  final sundayStartEditingController = new TextEditingController();
  final sundayEndEditingController = new TextEditingController();
  final mondayStartEditingController = new TextEditingController();
  final mondayEndEditingController = new TextEditingController();
  final tuesdayStartEditingController = new TextEditingController();
  final tuesdayEndEditingController = new TextEditingController();
  final wednesdayStartEditingController = new TextEditingController();
  final wednesdayEndEditingController = new TextEditingController();
  final thursdayStartEditingController = new TextEditingController();
  final thursdayEndEditingController = new TextEditingController();
  final fridayStartEditingController = new TextEditingController();
  final fridayEndEditingController = new TextEditingController();
  final saturdayStartEditingController = new TextEditingController();
  final saturdayEndEditingController = new TextEditingController();

  @override
  void initState() {
    sundayStartEditingController.text = "";
    sundayEndEditingController.text = "";
    mondayStartEditingController.text = "";
    mondayEndEditingController.text = "";
    tuesdayStartEditingController.text = "";
    tuesdayEndEditingController.text = "";
    wednesdayStartEditingController.text = "";
    wednesdayEndEditingController.text = "";
    thursdayStartEditingController.text = "";
    thursdayEndEditingController.text = "";
    fridayStartEditingController.text = "";
    fridayEndEditingController.text = "";
    saturdayStartEditingController.text = "";
    saturdayEndEditingController.text = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sundayStartField = TextFormField(
      autofocus: false,
      controller: sundayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,

      validator: (value) {},
      onSaved: (value) {
        sundayStartEditingController.text = value;
        mondayStartEditingController.text = value;
        tuesdayStartEditingController.text = value;
        wednesdayStartEditingController.text = value;
        thursdayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context)); //output 10:51 PM
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            sundayStartEditingController.text = formattedTime;
            mondayStartEditingController.text = formattedTime;
            tuesdayStartEditingController.text = formattedTime;
            wednesdayStartEditingController.text = formattedTime;
            thursdayStartEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },

      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final sundayEndField = TextFormField(
      autofocus: false,
      controller: sundayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        sundayEndEditingController.text = value;
        mondayEndEditingController.text = value;
        tuesdayEndEditingController.text = value;
        wednesdayEndEditingController.text = value;
        thursdayEndEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            sundayEndEditingController.text = formattedTime;
            mondayEndEditingController.text = formattedTime;
            tuesdayEndEditingController.text = formattedTime;
            wednesdayEndEditingController.text = formattedTime;
            thursdayEndEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final mondayStartField = TextFormField(
      autofocus: false,
      controller: mondayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        mondayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            mondayStartEditingController.text =
                formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final mondayEndField = TextFormField(
      autofocus: false,
      controller: mondayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        mondayEndEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            mondayEndEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final tuesdayStartField = TextFormField(
      autofocus: false,
      controller: tuesdayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        tuesdayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            tuesdayStartEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final tuesdayEndField = TextFormField(
      autofocus: false,
      controller: tuesdayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        tuesdayEndEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            tuesdayEndEditingController.text =
                formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final wednesdayStartField = TextFormField(
      autofocus: false,
      controller: wednesdayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        wednesdayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            wednesdayStartEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final wednesdayEndField = TextFormField(
      autofocus: false,
      controller: wednesdayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        wednesdayEndEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            wednesdayEndEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final thursdayStartField = TextFormField(
      autofocus: false,
      controller: thursdayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        thursdayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);
          setState(() {
            thursdayStartEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final thursdayEndField = TextFormField(
      autofocus: false,
      controller: thursdayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        thursdayEndEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            thursdayEndEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final fridayStartField = TextFormField(
      autofocus: false,
      controller: fridayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        fridayStartEditingController.text = value;
        saturdayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            fridayStartEditingController.text = formattedTime;
            saturdayStartEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final fridayEndField = TextFormField(
      autofocus: false,
      controller: fridayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        fridayEndEditingController.text = value;
        saturdayEndEditingController.text = value;

      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            fridayEndEditingController.text = formattedTime;
            saturdayEndEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final saturdayStartField = TextFormField(
      autofocus: false,
      controller: saturdayStartEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        saturdayStartEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);
          setState(() {
            saturdayStartEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final saturdayEndField = TextFormField(
      autofocus: false,
      controller: saturdayEndEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {},
      onSaved: (value) {
        saturdayEndEditingController.text = value;
      },
      onTap: () async {
        TimeOfDay pickedTime = await showTimePicker(
          initialTime: TimeOfDay.now(),
          context: context,
        );

        if (pickedTime != null) {
          print(pickedTime.format(context));
          DateTime parsedTime =
              DateFormat.jm().parse(pickedTime.format(context).toString());
          print(parsedTime);
          String formattedTime = DateFormat('HH:mm a').format(parsedTime);
          print(formattedTime);

          setState(() {
            saturdayEndEditingController.text = formattedTime;
          });
        } else {
          print("Time is not selected");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final addPlaceButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {

          if (sundayStartEditingController.text != "" &&
              sundayEndEditingController.text != "" &&
              mondayStartEditingController.text != "" &&
              mondayEndEditingController.text != "" &&
              tuesdayStartEditingController.text != "" &&
              tuesdayEndEditingController.text != "" &&
              wednesdayStartEditingController.text != "" &&
              wednesdayEndEditingController.text != "" &&
              thursdayStartEditingController.text != "" &&
              thursdayEndEditingController.text != "" &&
              fridayStartEditingController.text != "" &&
              fridayEndEditingController.text != "" &&
              saturdayStartEditingController.text != "" &&
              saturdayEndEditingController.text != "") {
            workingHours = [
              "Sunday : " +
                  sundayStartEditingController.text +
                  " - " +
                  sundayEndEditingController.text,
              "Monday : " +
                  mondayStartEditingController.text +
                  " - " +
                  mondayEndEditingController.text,
              "Tuesday : " +
                  tuesdayStartEditingController.text +
                  " - " +
                  tuesdayEndEditingController.text,
              "Wednesday : " +
                  wednesdayStartEditingController.text +
                  " - " +
                  wednesdayEndEditingController.text,
              "Thursday : " +
                  thursdayStartEditingController.text +
                  " - " +
                  thursdayEndEditingController.text,
              "Friday : " +
                  fridayStartEditingController.text +
                  " - " +
                  fridayEndEditingController.text,
              "Saturday : " +
                  saturdayStartEditingController.text +
                  " - " +
                  saturdayEndEditingController.text
            ];

            AlertDialogAddPlaceWorkingHours(context, () {
              postPlaceDateToFirestoreWorkingHours(workingHours, context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          addPlaceSocial(docId: widget.docId)));
            });
          } else {
            Fluttertoast.showToast(
              msg: "Please insure that you have entered information, or skip",
              toastLength: Toast.LENGTH_LONG,
            );

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
                      text: 'Working Hours',
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
                      "If you know the working hours of the place, please enter them, or skip",
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      )),

                  SizedBox(height: 30),
                  //open a form and call the fields that was created up
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(children: <Widget>[
                          Text("Sunday        "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: sundayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: sundayEndField),
                        ]),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(children: <Widget>[
                          Text("Monday       "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: mondayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: mondayEndField),
                        ]),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(children: <Widget>[
                          Text("Tuesday      "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: tuesdayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: tuesdayEndField),
                        ]),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(children: <Widget>[
                          Text("Wednesday "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: wednesdayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: wednesdayEndField),
                        ]),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(children: <Widget>[
                          Text("Thursday     "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: thursdayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: thursdayEndField),
                        ]),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(children: <Widget>[
                          Text("Friday           "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: fridayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: fridayEndField),
                        ]),
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(children: <Widget>[
                          Text("Saturday      "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: saturdayStartField),
                          Text(" - "),
                          SizedBox(
                              width: 100.0,
                              height: 70.0,
                              child: saturdayEndField),
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        addPlaceButton,
                        TextButton(
                            child: Text('Skip',
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue,
                                )),
                            onPressed: () {

                              if (sundayStartEditingController.text != "" ||
                                  sundayEndEditingController.text != "" ||
                                  mondayStartEditingController.text != "" ||
                                  mondayEndEditingController.text != "" ||
                                  tuesdayStartEditingController.text != "" ||
                                  tuesdayEndEditingController.text != "" ||
                                  wednesdayStartEditingController.text != "" ||
                                  wednesdayEndEditingController.text != "" ||
                                  thursdayStartEditingController.text != "" ||
                                  thursdayEndEditingController.text != "" ||
                                  fridayStartEditingController.text != "" ||
                                  fridayEndEditingController.text != "" ||
                                  saturdayStartEditingController.text != "" ||
                                  saturdayEndEditingController.text != ""){

                                AlertDialogSkip(context, () {
                                  postPlaceDateToFirestoreWorkingHours(wk, context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              addPlaceSocial(docId: widget.docId)));
                                });

                              }else{
                                postPlaceDateToFirestoreWorkingHours(wk, context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            addPlaceSocial(docId: widget.docId)));
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
        ],
      ),
    ));
  }

  void postPlaceDateToFirestoreWorkingHours(workingHours, context) async {
    var doc =
        FirebaseFirestore.instance.collection('newPlace').doc(widget.docId);
    var docRef = await doc.update({"WorkingHours": "$workingHours"});
  }

  AlertDialogAddPlaceWorkingHours(BuildContext context, onYes) {
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
