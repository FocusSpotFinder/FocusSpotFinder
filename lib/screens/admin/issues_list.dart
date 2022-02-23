import 'package:flutter/material.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/admin/admin_list_body.dart';
import 'package:focus_spot_finder/screens/app/app_page.dart';
import 'package:focus_spot_finder/screens/app/widget/bottom_nav.dart';
import 'package:focus_spot_finder/screens/app/widget/center_bottom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class issuesList extends StatefulWidget {
  final void Function() onBackPress;
  const issuesList({Key key, @required this.onBackPress}) : super(key: key);
  @override
  State<issuesList> createState() => _issuesListState();
}

class _issuesListState extends State<issuesList> {
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final issues = Issue();

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPress();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan.shade100,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 30),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          toolbarHeight: 55,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Image.asset('assets/chatbot.png',
                    fit: BoxFit.fitHeight, height: 40),
                tooltip: 'Chatbot',
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: adminListBody(),

        floatingActionButton: CenterBottomButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNav(
          onChange: (a) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (c) => AppPage(initialPage: a,)),
                    (route) => false);
          },

      ),
      ),
    );
  }
}
