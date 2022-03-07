import 'dart:math';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class passwordReset extends StatefulWidget {
  @override
  State<passwordReset> createState() => _passwordResetState();
}

class _passwordResetState extends State<passwordReset> {
  final _formKey = GlobalKey<FormState>();
  final emailEditingController = new TextEditingController();
  final _auth = FirebaseAuth.instance;
  final currentUser = UserModel();

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter your email");
        }
        //reg expression for email validator
        if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value)) {
          return ("Please enter a valid email\nIn the format: name@example.com");
        }
        return null;
      },
      onSaved: (value) {
        emailEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
          suffixIcon: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Email'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Your email must be in a valid format: name@example.com\n\nA reset link will be sent to the provided email if found"),
                      ),
                      actions: [
                        ElevatedButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    );
                  });
            },
            icon: Icon(Icons.info_outline),
          ),
          errorText: currentUser.resetNoEmail
              ? 'No user was found with the current email'
              : null,
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final resetButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            currentUser.resetPassword(emailEditingController.text, context);
          }
        },
        child: Text(
          'Reset',
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
                  SizedBox(height: height * .4),
                  //the title
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Reset Password',
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
                        emailField,
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(height: height * .055),
                        resetButton,
                      ],
                    ),
                  ),
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
}
