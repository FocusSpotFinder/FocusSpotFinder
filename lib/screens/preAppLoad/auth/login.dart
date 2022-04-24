import 'dart:math';
import 'package:focus_spot_finder/Widget/customClipper.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/password_reset.dart';
import 'package:focus_spot_finder/screens/preAppLoad/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); //key for the login form
  final emailEditingController = new TextEditingController(); //email controller
  final passwordEditingController = new TextEditingController(); //password controller
  final currentUser = UserModel(); //user object

  @override
  Widget build(BuildContext context) {
    //define the email field, assign the email controller
    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        //when submitted check if field is empty
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
      //when saved assign the text to the controller
      onSaved: (value) {
        emailEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail), //email icon at the beginning of the field
          suffixIcon: IconButton( //i icon at the end of the field, when clicked show the following dialog
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    //alert dialog that tells the user about this field
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
          //when there is error received show this message
          errorText: currentUser.emailNotValidated
              ? 'Please signup or validate your email'
              : null,
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    //define the password field, assign the password controller
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      validator: (value) {
        //vaildate the password if it meets strong password requirements
        //and check if field left empty when submitted
        RegExp regex = new RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
        if (value.isEmpty) {
          return ("Please enter your password");
        }
      },
      onSaved: (value) {
        passwordEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key), //password icon at the beginning of the field
          suffixIcon: IconButton(  //i icon at the end of the field, when clicked show the following dialog
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    //alert dialog that tells the user about this field
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Password'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Enter the password you enterd while signing up"),
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
          //when error recieved, show this message
          errorText: currentUser.wrongPassword
              ? 'Please enter the correct password'
              : null,
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    //set up the login button
    final loginButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {
          //when the button is pressed validate the fields, if validated call sign in method
          if (_formKey.currentState.validate()) {
            currentUser.signIn(emailEditingController.text,
                passwordEditingController.text, context);
          }
        },
        child: Text(
          'Log In',
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
          //show show the app title
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
                        passwordField,
                        SizedBox(
                          height: 60,
                        ),
                        loginButton,

                        //forgot password button
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                onPressed: () {
                                  //when clicked open password reset screen
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              passwordReset()));
                                },
                              )
                            ])
                        //
                      ],
                    ),
                  ),
                  SizedBox(height: height * .055),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Signup()));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding: EdgeInsets.all(15),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Don\'t have an account ?',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Sign Up',
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
          //back button at the top right corner
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

  //checks what type of error is based on the flags defined in login method
  String checkError() {
    if (currentUser.emailNotValidated) {
      return 'Email not verified';
    } else if (currentUser.wrongPassword) {
      return 'Please enter the correct password';
    }
  }
}
