import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/favorite_list_model.dart';
import 'package:focus_spot_finder/models/geometry.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:focus_spot_finder/screens/app/app_page.dart';
import 'package:focus_spot_finder/screens/controller.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app/widget/bottom_nav.dart';

class PlaceInfo extends StatefulWidget {
  final isFav;
  final Place place;
  final Geometry geo;

  PlaceInfo({this.place, @required this.isFav, @required this.geo});

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
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
    "Isolated Capsule Room",
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
    setState(() {});

    favorited = widget.isFav;
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
          favorited
              ? FavoriteButton(
            isFavorite: true,
            iconSize: 50,
            iconColor: Colors.red,
            iconDisabledColor: Colors.white,
            valueChanged: (_isFavorite) {
              print('Is Favorite $_isFavorite)');
              setState(() {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.uid)
                    .collection('Favorites')
                    .doc(widget.place.placeId)
                    .get()
                    .then((DocumentSnapshot documentSnapshot) {
                  if (documentSnapshot.exists) {
                    favoriteList.deleteItem(widget.place.placeId);
                  } else {
                    favoriteList.addItem(
                        widget.place.placeId,
                        widget.place.name,
                        widget.place.vicinity,
                        widget.place.types);
                  }
                });
              });
            },
          )
              : FavoriteButton(
            isFavorite: false,
            iconSize: 50,
            iconColor: Colors.red,
            iconDisabledColor: Colors.white,
            valueChanged: (_isFavorite) {
              print('Is Favorite $_isFavorite)');
              setState(() {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(user.uid)
                    .collection('Favorites')
                    .doc(widget.place.placeId)
                    .get()
                    .then((DocumentSnapshot documentSnapshot) {
                  if (documentSnapshot.exists) {
                    favoriteList.deleteItem(widget.place.placeId);
                  } else {
                    favoriteList.addItem(
                        widget.place.placeId,
                        widget.place.name,
                        widget.place.vicinity,
                        widget.place.types);
                  }
                });
              });
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.ios_share, color: Colors.white, size: 30),
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
      bottomNavigationBar: BottomNav(
        onChange: (a) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (c) => AppPage(initialPage: a,)),
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
              alertRate();
            } else if (value == 1) {
              alertReport();
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
                    'Rate & Review',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                value: 0,
              ),
              PopupMenuItem(
                height: 4,
                child: Container(
                  height: 2,
                  color: Colors.black,
                ),
              ),
              PopupMenuItem(
                child: Center(
                  child: Text(
                    'Report an Issue',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                value: 1,
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


  alertRate() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text("Rate",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.indigo.shade900,
                )),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 300.0, // Change as per your requirement
                width: 300.0,
                child: Column(children: [
                  Column(children: [
                    Text("Quiet",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                        }
                      },
                      onRatingUpdate: (rating) {
                        quietRate = rating;
                      },
                    ),
                  ]),
                  SizedBox(height: 15),
                  Column(children: [
                    Text("Crowded",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                        }
                      },
                      onRatingUpdate: (rating) {
                        crowdedRate = rating;
                      },
                    ),
                  ]),
                  SizedBox(height: 15),
                  Column(children: [
                    Text("Food Quality",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                        }
                      },
                      onRatingUpdate: (rating) {
                        foodRate = rating;
                      },
                    ),
                  ]),
                  SizedBox(height: 15),
                  Column(children: [
                    Text("Technical Facilities",
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        )),
                    RatingBar.builder(
                      initialRating: 0,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Icon(
                              Icons.sentiment_very_dissatisfied,
                              color: Colors.red,
                            );
                          case 1:
                            return Icon(
                              Icons.sentiment_neutral,
                              color: Colors.amber,
                            );
                          case 2:
                            return Icon(
                              Icons.sentiment_very_satisfied,
                              color: Colors.green,
                            );
                        }
                      },
                      onRatingUpdate: (rating) {
                        techRate = rating;
                      },
                    ),
                  ]),
                ]),
              ),
            ),
            actions: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                      quietRate = 0;
                      crowdedRate = 0;
                      foodRate = 0;
                      techRate = 0;
                    }),
                ElevatedButton(
                    child: Text("Next"),
                    onPressed: () {
                      if (quietRate != 0) {
                        if (crowdedRate != 0) {
                          if (foodRate != 0) {
                            if (techRate != 0) {
                              Navigator.pop(context);
                              alertReview();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please enter ratings");
                            }
                          } else {
                            Fluttertoast.showToast(msg: "Please enter ratings");
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Please enter ratings");
                        }
                      } else {
                        Fluttertoast.showToast(msg: "Please enter ratings");
                      }
                    })
              ])
            ],
          );
        });
  }

  alertReview() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text("Review",
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
              child: TextFormField(
                autofocus: false,
                controller: reviewEditingController,
                validator: (value) {},
                onSaved: (value) {
                  reviewEditingController.text = value;
                },
                textInputAction: TextInputAction.next,
                maxLines: 13,
                decoration: InputDecoration(
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: "Review",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
            ),
          ),
          actions: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                    quietRate = 0;
                    crowdedRate = 0;
                    foodRate = 0;
                    techRate = 0;
                    reviewEditingController.text = "";
                  }),
              ElevatedButton(
                  child: Text("Next"),
                  onPressed: () {
                    if (reviewEditingController.text != "") {
                      Navigator.pop(context);
                      alertServices();
                    } else {
                      Fluttertoast.showToast(msg: "Please enter review");
                    }
                  })
            ])
          ],
        );
      },
    );
  }

  alertServices() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Available Services",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300.0, // Change as per your requirement
                      width: 300.0,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _availableServices.length,
                          itemBuilder: (context, i) {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Center(
                                child: ListTile(
                                    title: Text(_availableServices[i],
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    trailing: Checkbox(
                                      //value: userChecked.contains(_availableServices[i]) || widget.place.services.contains(_availableServices[i]) ,
                                      value: userChecked
                                          .contains(_availableServices[i]),

                                      onChanged: (val) {
                                        setState(() {});
                                        _onSelected(val, _availableServices[i]);
                                      },
                                    )),
                              );
                            });
                          }),
                    )
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          child: Text('Skip',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              )),
                          onPressed: () {
                            if(userChecked.isNotEmpty){
                              AlertDialogSkip(context, () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                userChecked.clear();
                                alertAdditonalInfo();
                              });
                            }else{
                                Navigator.pop(context);
                                alertAdditonalInfo();
                            }



                          }),
                      ElevatedButton(
                          child: Text("Next"),
                          onPressed: () {
                            if(userChecked.isEmpty){
                              Fluttertoast.showToast(
                                msg: "Please insure that you have entered information, or skip",
                                toastLength: Toast.LENGTH_LONG,
                              );
                            }else {
                              Navigator.pop(context);
                              alertAdditonalInfo();
                            }
                          })
                    ])
              ],
            );
          },
        );
      },
    );
  }

  alertAdditonalInfo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Additional Information",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300.0,
                      width: 300.0,
                      child: Scrollbar(
                          isAlwaysShown: true,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                            TextFormField(
                              autofocus: false,
                              controller: phoneNumberEditingController,
                              keyboardType: TextInputType.phone,
                              validator: (value) {},
                              onSaved: (value) {
                                phoneNumberEditingController.text = value;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.phone),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Phone Number",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              autofocus: false,
                              controller: websiteEditingController,
                              validator: (value) {},
                              onSaved: (value) {
                                websiteEditingController.text = value;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  prefixIcon: Image.asset('assets/websiteGrey.jpg',
                                      height: 30, width: 30),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Website",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              autofocus: false,
                              controller: twitterEditingController,
                              validator: (value) {},
                              onSaved: (value) {
                                twitterEditingController.text = value;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  prefixIcon: Image.asset('assets/twitter.png',
                                      height: 20, width: 20),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "@Twitter",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextFormField(
                              autofocus: false,
                              controller: instagramEditingController,
                              validator: (value) {},
                              onSaved: (value) {
                                instagramEditingController.text = value;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                  prefixIcon: Image.asset('assets/instagram.png',
                                      width: 15, height: 15),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "@Instagram",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              child: MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  onPressed: () {
                                    myController.displayBottomSheet(context);
                                    setState(() {});
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,

                                      children: [
                                        Icon(Icons.local_see, size: 30, color: Colors.indigo.shade900),
                                        Text(
                                          ' Add photo',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.indigo.shade900,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ])),
                            ),

                            Container(
                              width: 50,
                              height: 55,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: FileImage(myController.f1.value),
                                ),
                              ),
                            ),

                          ],
                        ),
                      )
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          child: Text('Skip',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue,
                              )),
                          onPressed: () {
                            if(myController.f1.value.path.isNotEmpty ||
                                phoneNumberEditingController.text != "" ||
                            websiteEditingController.text != "" ||
                            twitterEditingController.text != "" ||
                            instagramEditingController.text != ""){
                              AlertDialogSkip(context, () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                myController.f1 = File('').obs;
                                phoneNumberEditingController.text = "";
                                websiteEditingController.text = "";
                                twitterEditingController.text = "";
                                instagramEditingController.text = "";
                                postRateAndReviewToFirestore(
                                    quietRate,
                                    crowdedRate,
                                    foodRate,
                                    techRate,
                                    reviewEditingController.text,
                                    userChecked,
                                    phoneNumberEditingController.text,
                                    websiteEditingController.text,
                                    twitterEditingController.text,
                                    instagramEditingController.text,
                                    photo,
                                    context);
                              });
                            }else{
                                Navigator.pop(context);
                                postRateAndReviewToFirestore(
                                    quietRate,
                                    crowdedRate,
                                    foodRate,
                                    techRate,
                                    reviewEditingController.text,
                                    userChecked,
                                    phoneNumberEditingController.text,
                                    websiteEditingController.text,
                                    twitterEditingController.text,
                                    instagramEditingController.text,
                                    photo,
                                    context);

                            }
                          }),
                      ElevatedButton(
                          child: Text("Submit"),
                          onPressed: () async {
                            if(myController.f1.value.path.isEmpty &&
                                phoneNumberEditingController.text == "" &&
                                websiteEditingController.text == "" &&
                                twitterEditingController.text == "" &&
                                instagramEditingController.text == ""){
                              Fluttertoast.showToast(
                                msg: "Please insure that you have entered information, or skip",
                                toastLength: Toast.LENGTH_LONG,
                              );
                            }else {
                              if (myController.f1.value != null && myController.f1.value.path.isNotEmpty ) {
                                photo = await uploadImageToStorage(myController.f1.value, widget.place.placeId);

                              }
                              Navigator.pop(context);
                              postRateAndReviewToFirestore(
                                  quietRate,
                                  crowdedRate,
                                  foodRate,
                                  techRate,
                                  reviewEditingController.text,
                                  userChecked,
                                  phoneNumberEditingController.text,
                                  websiteEditingController.text,
                                  twitterEditingController.text,
                                  instagramEditingController.text,
                                  photo,
                                  context);
                            }
                          },
                          ),
                    ],
                ),
              ],
            );
          },
        );
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


  void _onSelected(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userChecked.add(dataName);
      });
    } else {
      setState(() {
        userChecked.remove(dataName);
      });
    }
  }

  void postRateAndReviewToFirestore(
      double quiet,
      double crowded,
      double food,
      double tech,
      String review,
      List<String> services,
      String phone,
      String website,
      String twitter,
      String instagram,
      String photo,
      context) async {
    final _auth = FirebaseAuth.instance;
    User user = _auth.currentUser;
    String uid = user.uid;
    String placeId = widget.place.placeId;

    var collection = FirebaseFirestore.instance.collection('Review').doc();
    var docReff = await collection.set({"Review": "$review", "User ID": "$uid", "PlaceId": "$placeId"});

    var collection2 = FirebaseFirestore.instance.collection('Rate').doc();
    var docReff2 = await collection2.set({
      "User ID": "$uid",
      "PlaceId": "$placeId",
      "Quiet": "$quiet",
      "Crowded": "$crowded",
      "Food quality": "$food",
      "Technical facilities": "$tech"
    });

    if (phone == "") {
      phone = widget.place.phoneNumber;
    }
    if (website == "") {
      website = widget.place.website;
    }
    if (twitter == "") {
      twitter = widget.place.twitter;
    }
    if (instagram == "") {
      instagram = widget.place.instagram;
    }

    if(widget.place.placeId.length == 27) {
      var collection3 = FirebaseFirestore.instance
          .collection('googlePlace')
          .doc(widget.place.placeId);
      var docReff3 = await collection3.set({
        "Available services": "$services",
        "Phone number": "$phone",
        "Website": "$website",
        "Twitter": "$twitter",
        "Instagram": "$instagram",
        "PlaceId": "$placeId"
      });
    }else{
      var collection3 = FirebaseFirestore.instance
          .collection('newPlace')
          .doc(widget.place.placeId);
      var docReff3 = await collection3.update({
        "Available services": "$services",
        "Phone number": "$phone",
        "Website": "$website",
        "Twitter": "$twitter",
        "Instagram": "$instagram",
        "PlaceId": "$placeId"
      });
    }

    if(photo!= null){
      List<dynamic> photosList = widget.place.photos;
      photosList.add(photo);
      print(photosList.toString());
      if(widget.place.placeId.length == 27){
        var collection4 = FirebaseFirestore.instance
            .collection('googlePlace')
            .doc(widget.place.placeId);
        var docReff4 = await collection4.update({
          "Photos": "$photosList",});
      }else{
        var collection4 = FirebaseFirestore.instance
            .collection('newPlace')
            .doc(widget.place.placeId);
        var docReff4 = await collection4.update({
          "Photos": "$photosList",});
      }
    }else{
      if(widget.place.placeId.length == 27){
        var collection4 = FirebaseFirestore.instance
            .collection('googlePlace')
            .doc(widget.place.placeId);
        var docReff4 = await collection4.update({
          "Photos": "",});
      }
    }


    Fluttertoast.showToast(
      msg: "Rate & review submitted successfully",
      toastLength: Toast.LENGTH_LONG,
    );

    reviewEditingController.text = "";
    userChecked.clear();
    phoneNumberEditingController.text = "";
    websiteEditingController.text = "";
    twitterEditingController.text = "";
    instagramEditingController.text = "";
    myController.f1 = File('').obs;

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
            ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                })
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
            ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                })
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
            ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                })
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
            ElevatedButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.pop(context);
                })
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

  alertReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Report an Issue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300.0, // Change as per your requirement
                      width: 300.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.cyan.shade100,
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              onPressed: () {
                                Navigator.pop(context);
                                alertReportIncorrect();

                              },
                              child: Text('Incorrect information', style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Material(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.cyan.shade100,
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              onPressed: () {
                                Navigator.pop(context);
                                alertResieved();
                              },
                              child: Text('Place permanently closed', style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Material(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.cyan.shade100,
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              onPressed: () {
                                Navigator.pop(context);
                                alertResieved();
                              },
                              child: Text('Place not found', style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          Material(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.cyan.shade100,
                            child: MaterialButton(
                              minWidth: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              onPressed: () {
                                Navigator.pop(context);
                                alertReportOther();

                              },
                              child: Text('Other', style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.indigo.shade900,
                                  fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ])
              ],
            );
          },
        );
      },
    );
  }

  alertReportIncorrect() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Report an Issue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300.0,
                      width: 300.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text("Let us know what information is incorrect",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo.shade900,
                              )),

                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            autofocus: false,
                            controller: incorrectInfoEditingController,
                            validator: (value) {},
                            onSaved: (value) {
                              incorrectInfoEditingController.text = value;
                            },
                            textInputAction: TextInputAction.next,
                            maxLines: 9,
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Incorrect information",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                            incorrectInfoEditingController.text="";
                          }),
                      ElevatedButton(
                          child: Text("Submit"),
                          onPressed: () {
                            Navigator.pop(context);
                            alertResieved();
                          }),
                    ])
              ],
            );
          },
        );
      },
    );
  }

  alertReportOther() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Report an Issue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300.0,
                      width: 300.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text("Let us know what issues you faced",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo.shade900,
                              )),

                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            autofocus: false,
                            controller: otherEditingController,
                            validator: (value) {},
                            onSaved: (value) {
                              otherEditingController.text = value;
                            },
                            textInputAction: TextInputAction.next,
                            maxLines: 9,
                            decoration: InputDecoration(
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                hintText: "Other...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                )),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                            otherEditingController.text="";
                          }),
                      ElevatedButton(
                          child: Text("Submit"),
                          onPressed: () {
                            Navigator.pop(context);
                            alertResieved();
                          }),
                    ])
              ],
            );
          },
        );
      },
    );
  }

  alertResieved() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Report an Issue",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  )),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 300.0,
                      width: 300.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Image.asset('assets/report.png', fit: BoxFit.fitHeight, height: 100),
                          SizedBox(
                              height: 15
                          ),
                          Text("Thank You",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo.shade900,
                              )),

                          Text("Your report has been successfully sent to Focus Spot Finder team",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.indigo.shade900,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          child: Text("Close"),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ])
              ],
            );
          },
        );
      },
    );
  }

  Future<String> uploadImageToStorage(File imageFile, String docId) async {
    var url;
    var _data = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("newPlaceImages")
          .child(docId)
          .child("PlaceImages")
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

