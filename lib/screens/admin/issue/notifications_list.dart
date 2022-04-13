import 'package:flutter/material.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/admin/issue/notification_list_body.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_bottom_nav.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_center_bottom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class notificationsList extends StatefulWidget {
  final void Function() onBackPress;
    final Issue issue;
  const notificationsList({this.issue, Key key, @required this.onBackPress}) : super(key: key);

  @override
  State<notificationsList> createState() => _notificationsListState();
}

class _notificationsListState extends State<notificationsList> {
  bool isClicked = false;
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

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
        ),
        body: notificationsListBody(),

        floatingActionButton: AdminCenterBottomButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AdminBottomNav(
          onChange: (a) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (c) => AdminAppPage(initialPage: a,)),
                    (route) => false);
          },

        ),
      ),
    );
  }





}
