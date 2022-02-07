import 'dart:math';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  bool emailUsed = false;

  @override
  State<Signup> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  final nameEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final passwordConfirmEditingController = new TextEditingController();
  final currentUser = UserModel();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = new RegExp(r'^.{2,}$');
        if (value.isEmpty) {
          return ("Please enter your name");
        }
        if (!regex.hasMatch(value)) {
          return ("Please enter a valid name \nMinumum of 2 characters");
        }
        return null;
      },
      onSaved: (value) {
        nameEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle_rounded),
          suffixIcon: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Full Name'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Enter your first and last name"),
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
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Full Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter your email");
        }
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
                            "Your email must be in a valid format: name@example.com "),
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
          errorText: currentUser.emailUsed ? 'Email is already used' : null,
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (value) {
        RegExp regex = new RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
        if (value.isEmpty) {
          return ("Please enter your password");
        }
        if (!regex.hasMatch(value)) {
          return ("Please enter a valid password:\nMinumum of 8 characters\nUppercase and lowercase letters\nOne special character\nOne digit");
        }
      },
      onSaved: (value) {
        passwordEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          suffixIcon: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Password'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Your password must contain:\nUppercase and lowercase letters\nOne special character\nOne digit\nMinumum of 8 characters"),
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
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final passwordConfirmField = TextFormField(
      autofocus: false,
      controller: passwordConfirmEditingController,
      obscureText: true,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter your password");
        }
        if (passwordEditingController.text !=
            passwordConfirmEditingController.text) {
          return ("Passwords don't match");
        }
        return null;
      },
      onSaved: (value) {
        passwordConfirmEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          suffixIcon: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Confirm Password'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Re-type your password"),
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
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Confrim Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final signupButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            currentUser.signUp(
                emailEditingController.text,
                passwordEditingController.text,
                nameEditingController.text,
                context);
          }
        },
        child: Text(
          'Sign Up',
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
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Focus',
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.headline1,
                          fontSize: 80,
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo.shade900,
                        ),
                        children: [
                          TextSpan(
                            text: '\nSpot Finder',
                            style: TextStyle(
                                color: Colors.indigo.shade900, fontSize: 38),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          nameField,
                          SizedBox(
                            height: 30,
                          ),
                          emailField,
                          SizedBox(
                            height: 30,
                          ),
                          passwordField,
                          SizedBox(
                            height: 30,
                          ),
                          passwordConfirmField,
                          SizedBox(
                            height: 50,
                          ),
                          signupButton,
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()));
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Already have an account ?',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.indigo.shade900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
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
      ),
    );
  }
}
