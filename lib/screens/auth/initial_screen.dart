import 'package:focus_spot_finder/screens/auth/login.dart';
import 'package:focus_spot_finder/screens/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "assets/logo.png",
                fit: BoxFit.fill,
              ),
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
                height: 80,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Login()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Color(0xffe0f7fa).withAlpha(100),
                            offset: Offset(2, 4),
                            blurRadius: 8,
                            spreadRadius: 2)
                      ],
                      color: Colors.cyan.shade100),
                  child: Text(
                    'Log In',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //to detect any press on the sign up button
              GestureDetector(
                //when pressed
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Signup()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Colors.cyan.shade100, width: 2),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
