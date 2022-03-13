import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/favorite_list_model.dart';
import 'package:focus_spot_finder/models/geometry.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/admin/issue/edit_place.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_bottom_nav.dart';
import 'package:focus_spot_finder/Widget/controller.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';


class AdminPlaceInfo extends StatefulWidget {
  final Place place;
  final Geometry geo;

  AdminPlaceInfo({this.place, @required this.geo});

  @override
  State<AdminPlaceInfo> createState() => _AdminPlaceInfoState();
}

class _AdminPlaceInfoState extends State<AdminPlaceInfo> {
  final _auth = FirebaseAuth.instance;
  bool isClicked = false;
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool favorited = false;
  bool workingDaysButton = false;
  bool servicesButton = false;
  final geoService = GeoLocatorService();
  final favoriteList = FavoriteListModel();
  bool insertWorkingDaysButton = false;

  final reviewEditingController = new TextEditingController();
  final incorrectInfoEditingController = new TextEditingController();
  final otherEditingController = new TextEditingController();



  double quietRate = 0;
  double crowdedRate = 0;
  double foodRate = 0;
  double techRate = 0;
  List<String> _availableServices = [
    "WiFi",
    "Meetings Room",
    "Isolated Capsule",
    "Closed Room",
    "Outdoor Seating"
  ];
  List<String> userChecked = [];
  final phoneNumberEditingController = new TextEditingController();
  final websiteEditingController = new TextEditingController();
  final twitterEditingController = new TextEditingController();
  final instagramEditingController = new TextEditingController();

  var myController = Get.put(MyController());
  var photo;

  @override
  void initState() {
    userChecked = widget.place.services;

    setState(() {});

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
    return Scaffold(
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
              icon: Image.asset('assets/firebase.png',
                  fit: BoxFit.fitHeight, height: 32),
              tooltip: 'Firebase',
              onPressed: () {
                launchFirebase();
              },
            ),
          ),

          PopupMenuButton(
            icon: Icon(Icons.ios_share, color: Colors.white, size: 30),
            tooltip: 'Share',
            onSelected: (result) {
              switch (result) {
                case 'whatsapp':
                  print('whatsapp');
                  break;
                case 'SMS':
                  print('SMS');
                  break;
                case 'copy link':
                  print('copy link');
                  break;
                default:
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                value: 'Whatsapp',
                child: Row(
                  children: <Widget>[
                    Image.asset('assets/whatsapp.png',
                        fit: BoxFit.fill, height: 30),
                    Text(
                      "  WhatsApp",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'SMS',
                child: Row(
                  children: <Widget>[
                    Image.asset('assets/sms.png', fit: BoxFit.fill, height: 30),
                    Text(
                      "  SMS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy link',
                child: Row(
                  children: <Widget>[
                    Image.asset('assets/copy.png',
                        fit: BoxFit.fill, height: 30),
                    Text(
                      "  Copy Link",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
      //end appBar

      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                height: 9,
              ),
              widget.place.photos.isNotEmpty
                  ? CarouselSlider(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  autoPlay: true,
                ),
                items: widget.place.photos
                    .map((e) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        widget.place.getImage(e.replaceAll(' ',''))
                      ]),
                ))
                    .toList(),
              )
                  : SizedBox.shrink(),
              SizedBox(
                height: 7,
              ),
              Text(
                widget.place.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              (widget.place.types != null)
                  ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: typeFormat(widget.place.types))
                  : Row(),

              if (widget.place.openingHours.openNow == true)
                Text(
                  "Open",
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.green),
                  textAlign: TextAlign.center,
                )
              else
                Text(
                  "Close",
                  style: TextStyle(
                      fontWeight: FontWeight.normal, color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              if (widget.place.openingHours.workingDays.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      workingDaysButton = !workingDaysButton;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Working Days",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: Colors.black, size: 30),
                    ],
                  ),
                ),
              for (int i = 0;
              i < widget.place.openingHours.workingDays.length;
              i++)
                Visibility(
                  visible: workingDaysButton,
                  child: Text(
                    widget.place.openingHours.workingDays[i],
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 9,
              ),
              //titleSection,
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                GestureDetector(
                  onTap: () {
                    quietInfo();
                  },
                  child: Column(children: [
                    Text(
                      "\nQuiet",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 5.0,
                      percent: widget.place.quiet,
                      center: new Text(
                          (widget.place.quiet * 100).toStringAsFixed(0) + "%"),
                      progressColor: Colors.green,
                    ),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    crowdedInfo();
                  },
                  child: Column(children: [
                    Text(
                      "\nCrowded",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 5.0,
                      percent: widget.place.crowded,
                      center: new Text(
                          (widget.place.crowded * 100).toStringAsFixed(0) +
                              "%"),
                      progressColor: Colors.blue,
                    ),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    foodInfo();
                  },
                  child: Column(children: [
                    Text(
                      "Food\nQuality",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 5.0,
                      percent: widget.place.food,
                      center: new Text(
                          (widget.place.food * 100).toStringAsFixed(0) + "%"),
                      progressColor: Colors.red,
                    ),
                  ]),
                ),
                GestureDetector(
                  onTap: () {
                    techInfo();
                  },
                  child: Column(children: [
                    Text(
                      "Technical\nFacilities",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 5.0,
                      percent: widget.place.tech,
                      center: new Text(
                          (widget.place.tech * 100).toStringAsFixed(0) + "%"),
                      progressColor: Colors.yellow,
                    ),
                  ]),
                ),
              ]),
              SizedBox(
                height: 9,
              ),

              if (widget.place.services.isNotEmpty)
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      servicesButton = !servicesButton;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Available Services",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: Colors.black, size: 30),
                    ],
                  ),
                ),
              for (int i = 0; i < widget.place.services.length; i++)
                Visibility(
                  visible: servicesButton,
                  child: Text(
                    widget.place.services[i],
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                height: 15,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Image.asset('assets/googleMap.png'),
                    iconSize: 40,
                    onPressed: () {
                      alertDialogGoogleNav(context, () {
                        geoService.openMap(
                            widget.geo.location.lat, widget.geo.location.lng);
                        Navigator.pop(context);
                      });
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/twitter.png'),
                    iconSize: 60,
                    onPressed: () {
                      launchTwitter(widget.place.twitter);
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/instagram.png'),
                    iconSize: 60,
                    onPressed: () {
                      launchInstagram(widget.place.instagram);
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/website.png'),
                    iconSize: 40,
                    onPressed: () {
                      launchWebsite(widget.place.website);
                    },
                  ),
                  IconButton(
                    icon: Image.asset('assets/phone.png'),
                    iconSize: 40,
                    onPressed: () {
                      launchPhone(widget.place.phoneNumber);
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Reviews',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              (widget.place.reviewsList.isNotEmpty)
                  ? Row(
                children: [
                  new Flexible(
                    child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 7.0),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: widget.place.reviewsList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 50,
                            child: ListTile(
                              isThreeLine: true,
                              shape: RoundedRectangleBorder(),
                              title: Text(
                                "${widget.place.reviewsList[index][0]}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.place.reviewsList[index][1]}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              )
                  : Text(
                "No reviews found\n  \n ",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          isClicked
              ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black45,
          )
              : SizedBox(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: myPopMenu(context),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AdminBottomNav(
        onChange: (a) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (c) => AdminAppPage(initialPage: a,)),
                  (route) => false);
        },
      ),
    );
  }

  Widget myPopMenu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white60,
      ),
      child: PopupMenuButton(
          offset: const Offset(-60, -130),
          icon: Image.asset('assets/logo.png', fit: BoxFit.cover, height: 40),
          onCanceled: () {
            setState(() {
              isClicked = false;
            });
          },
          onSelected: (value) {
            setState(() {
              isClicked = false;
            });

            print('pop up clicked');
            if (value == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>editPlace(place: widget.place)
                ),
              );
            }
          },
          itemBuilder: (context) {
            setState(() {
              isClicked = true;
            });

            return [
              PopupMenuItem(
                child: Center(
                  child: Text(
                    'Edit place',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                value: 0,
              ),
            ];
          }),
    );
  }

  alertDialogGoogleNav(BuildContext context, onYes) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton =
    TextButton(child: Text("Continue"), onPressed: onYes);
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      //title: Text(""),
      content: Text("Would you like to open Google Maps?"),
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

  Future<void> launchPhone(String phonee) async {
    String phone = "tel:" + phonee;
    if (phonee == "") {
      Fluttertoast.showToast(
        msg: "Could not call this phone number",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not call this phone number';
    } else if (await canLaunch(phone)) {
      await launch(phone);
    } else {
      Fluttertoast.showToast(
        msg: "Could not call this phone number",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not call this phone number';
    }
  }

  Future<void> launchWebsite(String url) async {
    String finalUrl = 'https://' + url;

    if (url == "") {
      Fluttertoast.showToast(
        msg: "Could not open this website",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this website';
    } else if (await canLaunch(finalUrl)) {
      await launch(finalUrl);
    } else {
      Fluttertoast.showToast(
        msg: "Could not open this website",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this website';
    }
  }

  Future<void> launchInstagram(String url) async {
    String finalUrl = 'https://www.instagram.com/' + url.replaceAll("@", "");

    if (url == "") {
      Fluttertoast.showToast(
        msg: "Could not open this account",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this account';
    } else if (await canLaunch(finalUrl)) {
      await launch(finalUrl);
    } else {
      Fluttertoast.showToast(
        msg: "Could not open this account",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this account';
    }
  }

  Future<void> launchTwitter(String url) async {
    String finalUrl = 'http://twitter.com/' + url.replaceAll("@", "");

    if (url == "") {
      Fluttertoast.showToast(
        msg: "Could not open this account",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this account';
    } else if (await canLaunch(finalUrl)) {
      await launch(finalUrl);
    } else {
      Fluttertoast.showToast(
        msg: "Could not open this account",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this account';
    }
  }

  quietInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text("Quiet",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.indigo.shade900,
              )),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                height: 300.0,
                width: 300.0,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Indicated the place level of quietness",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo.shade900,
                          )),
                      SizedBox(
                        height: 40,
                      ),
                      CircularPercentIndicator(
                        radius: 150.0,
                        lineWidth: 10.0,
                        percent: widget.place.quiet,
                        center: new Text(
                          (widget.place.quiet * 100).toStringAsFixed(0) + "%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        progressColor: Colors.green,
                      ),
                    ])),
          ),
          actions: [
            SizedBox(
                height: 36,
                width: 85,
                child: ElevatedButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
            ),
          ],
        );
      },
    );
  }

  crowdedInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text("Crowded",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.indigo.shade900,
              )),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                height: 300.0,
                width: 300.0,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Indicated the place level of crowdedness",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo.shade900,
                          )),
                      SizedBox(
                        height: 40,
                      ),
                      CircularPercentIndicator(
                        radius: 150.0,
                        lineWidth: 10.0,
                        percent: widget.place.crowded,
                        center: new Text(
                          (widget.place.crowded * 100).toStringAsFixed(0) + "%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        progressColor: Colors.blue,
                      ),
                    ])),
          ),
          actions: [
            SizedBox(
                height: 36,
                width: 85,
                child: ElevatedButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
            ),
          ],
        );
      },
    );
  }

  foodInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text("Food Quality",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.indigo.shade900,
              )),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                height: 300.0,
                width: 300.0,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("The place food quality goodness",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo.shade900,
                          )),
                      SizedBox(
                        height: 40,
                      ),
                      CircularPercentIndicator(
                        radius: 150.0,
                        lineWidth: 10.0,
                        percent: widget.place.food,
                        center: new Text(
                          (widget.place.food * 100).toStringAsFixed(0) + "%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        progressColor: Colors.red,
                      ),
                    ])),
          ),
          actions: [
            SizedBox(
                height: 36,
                width: 85,
                child:  ElevatedButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
            ),
          ],
        );
      },
    );
  }

  techInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text("Technical Facilities",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.indigo.shade900,
              )),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                height: 300.0,
                width: 300.0,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Measures the place technical facilities, such as cables, WiFi, computers, etc.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo.shade900,
                          )),
                      SizedBox(
                        height: 40,
                      ),
                      CircularPercentIndicator(
                        radius: 150.0,
                        lineWidth: 10.0,
                        percent: widget.place.tech,
                        center: new Text(
                          (widget.place.tech * 100).toStringAsFixed(0) + "%",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        progressColor: Colors.yellow,
                      ),
                    ])),
          ),
          actions: [
            SizedBox(
                height: 36,
                width: 85,
                child: ElevatedButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
            ),
          ],
        );
      },
    );
  }

  List<Text> typeFormat(List list) {
    List<Text> T = [];

    for (int i = 0; i < list.length && i < 2; i++) {
      if (list[i] != null) {
        if (i == 0) {
          T.add(Text(list[i].replaceAll('_', ' ').toString()));
        } else {
          T.add(Text(' \u00b7 ' + list[i].replaceAll('_', ' ').toString()));
        }
      }
    }
    return T;
  }

  Future<void> launchFirebase() async {
    String url = "https://firebase.google.com/?gclid=Cj0KCQiAmeKQBhDvARIsAHJ7mF6OmPIeu2W7gn63okFHkH8LhJvzQ7fQhWAUKbBA49A0IutQzYCMBEgaArhQEALw_wcB&gclsrc=aw.ds";

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
        msg: "C ould not open this website",
        toastLength: Toast.LENGTH_LONG,
      );
      throw 'Could not open this website';
    }
  }


}