import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/screens/app/home.dart';
import 'package:focus_spot_finder/screens/auth/initial_screen.dart';
import 'package:focus_spot_finder/screens/auth/signup.dart';
import 'package:focus_spot_finder/screens/splash_screen.dart';

class UserModel {
  String uid;
  String name;
  String email;
  String country;
  String gender;
  String profileImage;
  DateTime birthday;
  final currentUser = Signup();

  UserModel(
      {this.uid,
      this.name,
      this.email,
      this.country,
      this.gender,
      this.birthday,
      this.profileImage});

  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      country: map['country'],
      gender: map['gender'],
      profileImage: map['profileImage'],
      birthday:
          map['birthday'] != null ? map['birthday'].toDate() : DateTime.now(),
    );
  }

  //send data to the database
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'country': country,
      'birthday': birthday,
      'profileImage': profileImage,
      'gender': gender,
    };
  }

  bool emailUsed = false;

  void signUp(String email, String password, String name, context) async {
    final _auth = FirebaseAuth.instance;
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      value.user.sendEmailVerification();
      //post details to firestore
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      User user = _auth.currentUser;
      UserModel userModel = UserModel();
      userModel.email = user.email;
      userModel.uid = user.uid;
      userModel.name = name;
      userModel.country = "SA";
      await firebaseFirestore
          .collection("Users")
          .doc(user.uid)
          .set(userModel.toMap());
      alertDialogEmailConfirm(context, () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => InitialScreen()),
            (route) => false);
      });
    }).catchError((e) {
      emailUsed = true;
      (context as Element).markNeedsBuild();
    });
  }

  //shows confirmation message and ask to validate their email
  alertDialogEmailConfirm(BuildContext context, onYes) {
    // set up the buttons
    Widget continueButton = TextButton(child: Text("OK"), onPressed: onYes);
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Account Created Successfully"),
      content: Text("Please verify your email to sign in"),
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

  bool emailNotFound = false;
  bool emailNotValidated = false;
  bool wrongPassword = false;

  void signIn(String email, String password, context) async {
    final _auth = FirebaseAuth.instance;
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
      if (user.user.emailVerified) {
        Fluttertoast.showToast(
          msg: "Login Successful",
          toastLength: Toast.LENGTH_LONG,
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SplashScreen()));
      } else {
        emailNotValidated = true;
      }
    }).catchError((e) {
      //  if (e.code == 'auth/wrong-password') {
      wrongPassword = true;
      (context as Element).markNeedsBuild();

      // }
    });
  }

  bool resetNoEmail = false;
  void resetPassword(String email, context) async {
    final _auth = FirebaseAuth.instance;
    await _auth.sendPasswordResetEmail(email: email).then((user) {
      Fluttertoast.showToast(
        msg: "Reset link has been sent to your email",
        toastLength: Toast.LENGTH_LONG,
      );
      Navigator.of(context).pop();
    }).catchError((error) {
      resetNoEmail = true;
      (context as Element).markNeedsBuild();
    });
  }

  alertDialogSignOut(BuildContext context, onYes) {
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
      content: Text("Are sure you want to sign out?"),
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

  Future<void> logout(BuildContext context) async {
    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => InitialScreen()));
  }
}
