import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_bottom_nav.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_center_bottom_button.dart';
import 'package:get/get.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/Widget/controller.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Widget/customClipper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:country_list_pick/country_list_pick.dart';


class AdminProfileInfo extends StatefulWidget {
  @override
  State<AdminProfileInfo> createState() => _AdminProfileInfoState();
}

class _AdminProfileInfoState extends State<AdminProfileInfo> {
  final _formKey = GlobalKey<FormState>();
  var myController = Get.put(MyController());
  bool isClicked = false;
  DateTime age;
  final _auth = FirebaseAuth.instance;
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final nameEditingController = TextEditingController();
  String initialCity;

  @override
  void initState() {
    getUserData();
    Logger().i("yoyo");
    age = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width,
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
            color: Colors.cyan.shade50),
        child: Center(
          child: TextFormField(
            autofocus: false,
            controller: nameEditingController,
            keyboardType: TextInputType.name,
            validator: (value) {
              RegExp regex = new RegExp(r'^.{2,}$');
              if (value.isEmpty) {
                return ("Please Enter Your Name");
              }
              if (!regex.hasMatch(value)) {
                return ("Please Enter a Valid Name, (Minumum of 2 Characters");
              }
              return null;
            },
            onSaved: (value) {
              nameEditingController.text = value;
            },
            textInputAction: TextInputAction.next,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              prefixIcon: Icon(
                Icons.account_circle_rounded,
                size: 35,
              ),
              // fillColor: Colors.grey.withOpacity(0.8),
              fillColor: Colors.cyan.shade50,
              filled: true,
              hintText: "Full Name",
              hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.4)),
            ),
          ),
        ),
      ),
    );

    final cityField = Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width,
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
            color: Colors.cyan.shade50),
        child: Center(
          child: initialCity == null
              ? SizedBox()
              : CountryListPick(

            pickerBuilder: (context, CountryCode countryCode) {
              return Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween,

                children: [
                  Icon(Icons.add_location_rounded,
                      size: 35, color: Colors.black.withOpacity(0.4)),
                  Text(countryCode.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.4))),
                  Icon(Icons.keyboard_arrow_down,
                      size: 35, color: Colors.black.withOpacity(0.4)),
                ],
              );
            },

            initialSelection: initialCity ?? "DZ",


            onChanged: (CountryCode code) {
              print(code.name);
              initialCity = code.code;
            },
          ),
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade100,
        leading: IconButton(
          icon:
          Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 30),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 55,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Image.asset('assets/firebase.png',
                  fit: BoxFit.fitHeight, height: 32),
              tooltip: 'Firebase',
              onPressed: () {
                launchFirebase();
              },
            ),
          ),
        ],
      ),
      //end appBar

      body: Stack(
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
          Form(
            key: _formKey,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Obx(
                              () => CircleAvatar(
                            radius: MediaQuery.of(context).size.height * 0.1,
                            backgroundColor:
                            Colors.cyan.shade100.withOpacity(0.8),
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  myController.f1.value.path.isEmpty
                                      ? (loggedInUser.profileImage != null &&
                                      loggedInUser
                                          .profileImage.isNotEmpty)
                                      ? CircleAvatar(
                                    backgroundColor:
                                    Colors.transparent,
                                    radius: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.1,
                                    backgroundImage: NetworkImage(
                                        loggedInUser.profileImage),
                                  )
                                      : CircleAvatar(
                                      backgroundColor:
                                      Colors.transparent,
                                      radius: MediaQuery.of(context)
                                          .size
                                          .height *
                                          0.1,
                                      backgroundImage: AssetImage(
                                        'assets/place_holder.png',
                                      ))
                                      : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.1,
                                    backgroundImage:
                                    FileImage(myController.f1.value),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: InkWell(
                                      onTap: () {
                                        print('open bottom sheet');

                                        myController
                                            .displayBottomSheet(context);
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.cyan.shade100
                                            .withOpacity(0.8),
                                        radius: 26,
                                        child: Icon(
                                          Icons.local_see,
                                          color: Colors.black45,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02),
                        Column(
                          children: [
                            Text("Admin: ${myController.userName.value}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  fontFamily: "Poppins",
                                )),
                            SizedBox(
                                height:
                                MediaQuery.of(context).size.height * 0.003),
                          ],
                        )
                      ],
                    ),
                  ),
                  nameField,
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      selectDate(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width,
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
                            color: Colors.cyan.shade50),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.calendar_today_sharp,
                                    color: Colors.black.withOpacity(0.5)),
                                Text(
                                  "Birthday:  "
                                      "  ${age.day}/${age.month}/${age.year}",                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.4)),
                                ),
                                SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: genderPopMenu(
                      context: context,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  cityField,
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: MaterialButton(
                      onPressed: () {
                        showAlertDialog(context, () {
                          saveInfo(
                            nameEditingController.text,
                            initialCity,
                          );
                          Navigator.pop(context);
                        });
                      },
                      color: Colors.cyan.shade100,
                      height: MediaQuery.of(context).size.height * 0.05,
                      minWidth: MediaQuery.of(context).size.width * 0.3,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: AdminCenterBottomButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AdminBottomNav(
        onChange: (a) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (c) => AdminAppPage(
                    initialPage: a,
                  )),
                  (route) => false);
        },
      ),
    );
  }

  selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: age,
      firstDate: DateTime(1960),
      lastDate: DateTime(2090),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.cyan.shade100, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Colors.cyan.shade100, // button text color
              ),
            ),
          ),
          child: child,
        );
      },
    );
    if (selected != null && selected != age) {
      setState(() {
        age = selected;
      });
    }
  }

  bool isAdult(DateTime birthDate) {
    DateTime today = DateTime.now();
    DateTime adultDate = DateTime(
      birthDate.year + 18,
      birthDate.month,
      birthDate.day,
    );

    return adultDate.isBefore(today);
  }

  Widget genderPopMenu({BuildContext context, double height, double width}) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white60,
      ),
      child: PopupMenuButton(
        offset: const Offset(100, 0),
        elevation: 5,
        child: Container(
          height: height * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.cyan.shade50,
          ),
          child: Center(
            child: Container(
              height: height * 0.055,
              width: width,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/gender.png'),
                      onPressed: null,
                    ),
                    Obx(
                          () => Text(
                        myController.dropDownText.value,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.4)),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 35,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        onCanceled: () {},
        onSelected: (value) {
          print('pop up clicked');
          print('valueee $value');
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Center(
                child: Container(
                  width: width,
                  child: Text(
                    'Male',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              onTap: () {
                myController.dropDownText.value = 'Male';
              },
            ),
            PopupMenuItem(
              child: Center(
                child: Container(
                  width: width,
                  child: Text(
                    'Female',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              onTap: () {
                myController.dropDownText.value = 'Female';
              },
            ),
          ];
        },
      ),
    );
  }

  void saveInfo(String name, String city) async {
    if (_formKey.currentState.validate()) {
      if (isAdult(age)) {
        await postDetailsToFirestore();
      } else {
        Fluttertoast.showToast(
          msg: "Age must be greater than 18",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    }
  }

  postDetailsToFirestore() async {
    //call fire store
    //call user model
    //send values

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.email = user.email;
    userModel.uid = user.uid;
    userModel.name = nameEditingController.text;
    userModel.country = initialCity;
    userModel.gender = myController.dropDownText.value;
    userModel.birthday = age;
    myController.userName.value = nameEditingController.text;
    userModel.profileImage = loggedInUser.profileImage;

    if (myController.f1.value != null &&
        myController.f1.value.path.isNotEmpty) {
      userModel.profileImage =
      await uploadImageToStorage(myController.f1.value, user.uid);
    }

    await firebaseFirestore
        .collection("Users")
        .doc(user.uid)
        .set(userModel.toMap());
    Fluttertoast.showToast(
      msg: "Your Profile has been updated Successfully",
      toastLength: Toast.LENGTH_LONG,
    );
    Navigator.pop(
      context,
    );
  }

  void getUserData() async {
    var _data = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get();
    Logger().wtf(_data.data());
    this.loggedInUser = UserModel.fromMap(_data.data());
    nameEditingController.text = loggedInUser.name;
    if (loggedInUser.country.isNotEmpty) initialCity = loggedInUser.country;
    if (loggedInUser.gender != null && loggedInUser.gender.isNotEmpty)
      myController.dropDownText.value = loggedInUser.gender;
    if (loggedInUser.birthday != null) age = loggedInUser.birthday;
    setState(() {});
  }

  static Future<String> uploadImageToStorage(
      File imageFile, String userId) async {
    var url;
    var _data = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("UserImages")
          .child(userId)
          .child("Profile")
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
}

showAlertDialog(BuildContext context, onYes) {
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
    content: Text("Save all changes?"),
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
Future<void> launchFirebase() async {
  String url = "https://firebase.google.com/?gclid=Cj0KCQiAmeKQBhDvARIsAHJ7mF6OmPIeu2W7gn63okFHkH8LhJvzQ7fQhWAUKbBA49A0IutQzYCMBEgaArhQEALw_wcB&gclsrc=aw.ds";

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    Fluttertoast.showToast(
      msg: "Could not open this website",
      toastLength: Toast.LENGTH_LONG,
    );
    throw 'Could not open this website';
  }
}