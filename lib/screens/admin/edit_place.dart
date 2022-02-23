import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/models/location.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/app/app_page.dart';
import 'package:focus_spot_finder/screens/app/widget/bottom_nav.dart';
import 'package:focus_spot_finder/screens/app/widget/center_bottom_button.dart';
import 'package:focus_spot_finder/screens/place_info.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class editPlace extends StatefulWidget {
  final void Function() onBackPress;
  final Place place;

  const editPlace({this.place, Key key, @required this.onBackPress}) : super(key: key);

  @override
  State<editPlace> createState() => _editPlaceState();
}

class _editPlaceState extends State<editPlace> {
  bool isClicked = false;
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final nameEditingController = new TextEditingController();
  final typesEditingController = new TextEditingController();
  List<String> _types = ['Cafe', 'cafe', 'food', 'Library', 'Book Store', 'Park'];
  List<String> userChecked = [];
  final phoneNumberEditingController = new TextEditingController();
  final vicinityEditingController = new TextEditingController();
  List<String> _availableServices = [
    "WiFi",
    "Meetings Room",
    "Isolated Capsule",
    "Closed Room",
    "Outdoor Seating"
  ];
  List<String> userCheckedServices = [];
  final hoursEditingController = new TextEditingController();
  final websiteEditingController = new TextEditingController();
  final twitterEditingController = new TextEditingController();
  final instagramEditingController = new TextEditingController();
  Set<Marker> _markers = Set();
  double lat;
  double lng;

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

    nameEditingController.text = widget.place.name;
    typesEditingController.text = typeFormat(widget.place.types).join(', ');
    vicinityEditingController.text = widget.place.vicinity;
    userCheckedServices = widget.place.services;
    phoneNumberEditingController.text = widget.place.phoneNumber;
    websiteEditingController.text = widget.place.website;
    twitterEditingController.text = widget.place.twitter;
    instagramEditingController.text = widget.place.instagram;
    hoursEditingController.text = widget.place.openingHours.workingDays.join(",\n");
    lat = widget.place.geometry.location.lat;
    lng = widget.place.geometry.location.lng;
    LatLng latlng = new LatLng (lat, lng);
    _markers.add(Marker(markerId: MarkerId('mark'), position: latlng));

    print(widget.place.geometry.location.lat);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    final nameField = TextFormField(
      autofocus: false,
      controller: nameEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter place name");
        }
        return null;
      },
      onSaved: (value) {
        nameEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.label),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final typesField = TextFormField(
      autofocus: false,
      controller: typesEditingController,
      keyboardType: TextInputType.name,
      readOnly: true,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter place type");
        }
        return null;
      },
      onSaved: (value) {
        typesEditingController.text = value;
      },
      onTap: () {
        alertTypes();
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.dashboard_outlined),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Types",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final vicinityField = TextFormField(
      autofocus: false,
      controller: vicinityEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value.isEmpty) {
          return ("Please enter place address");
        }
        return null;
      },
      onSaved: (value) {
        vicinityEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.label),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Address",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final workingHoursField = TextFormField(
      autofocus: false,
      controller: hoursEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value.isEmpty) {
        }
        return null;
      },
      onSaved: (value) {
        hoursEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      maxLines: 8,
      decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom:160),
            child: Icon(Icons.access_time_rounded
            ),
          ),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Working Hours",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final phoneNumberField = TextFormField(
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
    );
    final websiteField = TextFormField(
      autofocus: false,
      controller: websiteEditingController,
      validator: (value) {},
      onSaved: (value) {
        websiteEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon:
          Image.asset('assets/websiteGrey.jpg', height: 30, width: 30),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "Website",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final twitterField = TextFormField(
      autofocus: false,
      controller: twitterEditingController,
      validator: (value) {},
      onSaved: (value) {
        twitterEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Image.asset('assets/twitter.png', height: 20, width: 20),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "@Twitter",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final instagramField = TextFormField(
      autofocus: false,
      controller: instagramEditingController,
      validator: (value) {},
      onSaved: (value) {
        instagramEditingController.text = value;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon:
          Image.asset('assets/instagram.png', width: 15, height: 15),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: "@Instagram",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final updateButton = Material(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.cyan.shade100,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        onPressed: () {
          AlertDialogUpdate(context, () {
            updatePlaceDateToFirestore(
                widget.place.placeId,
                nameEditingController.text,
                typesEditingController.text,
                lat,
                lng,
                vicinityEditingController.text,
                userCheckedServices.toString(),
                hoursEditingController.text,
                phoneNumberEditingController.text,
                websiteEditingController.text,
                twitterEditingController.text,
                instagramEditingController.text,
                widget.place.photos,
                context);
          });
        },
        child: Text(
          'Update Place',
          style: TextStyle(
              fontSize: 20,
              color: Colors.indigo.shade900,
              fontWeight: FontWeight.bold),
        ),
      ),
    );


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
        body:  Stack(
            children: <Widget> [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 15,
                            ),
                            Text("Edit Place ",
                                style: GoogleFonts.lato(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                      width: 350,
                                      child: nameField
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Types ",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                      width: 350,
                                      child: typesField
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Location",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child:  Container(
                                      height: MediaQuery.of(context).size.height / 3,
                                      width: MediaQuery.of(context).size.width,
                                      child: GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                            target: LatLng(lat,lng),
                                            zoom: 16.0),
                                        zoomGesturesEnabled: true,
                                        myLocationEnabled: true,
                                        myLocationButtonEnabled: true,
                                        compassEnabled: true,
                                        tiltGesturesEnabled: true,
                                        markers: Set<Marker>.of(_markers),
                                        onTap: (LatLng latLng) {
                                          _markers.add(
                                            Marker(
                                              markerId: MarkerId('mark'),
                                              position: latLng,
                                            ),
                                          );
                                          print('${latLng.latitude}, ${latLng.longitude}');
                                          lat = latLng.latitude;
                                          lng = latLng.longitude;
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Address",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                      width: 350,
                                      child: vicinityField,
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Available Services",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                      width: 350,
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            // height: 300, // constrain height
                                            child: ListView.builder(
                                                physics: const NeverScrollableScrollPhysics(),

                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                itemCount: _availableServices.length,
                                                itemBuilder: (context, i) {
                                                  return ListTile(
                                                      title: Text(_availableServices[i],
                                                          style: GoogleFonts.lato(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.black,
                                                          )),
                                                      trailing: Checkbox(
                                                        value: userCheckedServices
                                                            .contains(_availableServices[i]) ||widget.place.services
                                                            .contains(_availableServices[i]),
                                                        onChanged: (val) {
                                                          _onSelectedServices(val, _availableServices[i]);
                                                        },
                                                      )
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Working Hours",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child: workingHoursField,
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Phone Number ",
                                      //textAlign: TextAlign.start,
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                      width: 350,
                                      child: phoneNumberField
                                  )
                                ]
                            ),

                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Website",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                      width: 350,
                                      child: websiteField,
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Twitter",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child: twitterField,
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Instagram",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),

                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child: instagramField,
                                  )
                                ]
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            (widget.place.photos.isNotEmpty)?
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Photos",
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      )),
                                  Text("Click on the photo you would like to delete",
                                      style: GoogleFonts.lato(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueGrey,
                                      )),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width: 350,
                                    child: widget.place.photos.isNotEmpty
                                        ? CarouselSlider(
                                      options: CarouselOptions(

                                        enlargeCenterPage: true,
                                        enableInfiniteScroll: false,
                                        autoPlay: false,
                                      ),
                                      items: widget.place.photos
                                          .map((e) => ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: GestureDetector(
                                          onTap: () {
                                            print(e);
                                            AlertDialogDeletePhoto(context, () {
                                              Navigator.of(context).pop();


                                            });
                                          },
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: <Widget>[
                                              widget.place.getImage(e.replaceAll(' ',''))
                                            ]),
                                      )
                                      ))
                                          .toList(),
                                    )
                                        : SizedBox.shrink(),
                                  )
                                ]
                            ): SizedBox.shrink(),

                            SizedBox(
                              height: 25,
                            ),

                            updateButton,

                            SizedBox(
                              height: 35,
                            ),
                          ])
                  )
              )


            ]
        ),

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

  AlertDialogDeletePhoto(BuildContext context, onYes) {
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
      content: Text("Are sure you want to delete this photo?"),
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

  alertTypes() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Place Type",
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
                      height: 250.0, // Change as per your requirement
                      width: 300.0,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _types.length,
                          itemBuilder: (context, i) {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Center(
                                child: ListTile(
                                    title: Text(_types[i],
                                        style: GoogleFonts.lato(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                        )),
                                    trailing: Checkbox(
                                      value: userChecked.contains(_types[i]) || widget.place.types.contains(_types[i]),
                                      onChanged: (val) {
                                        setState(() {});
                                        _onSelected(val, _types[i]);
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
                ElevatedButton(
                    child: Text("Close"),
                    onPressed: () {
                      typesEditingController.text = userChecked.join(", ");
                      Navigator.pop(context);
                    })
              ],
            );
          },
        );
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

  List<String> typeFormat(List list) {
    List<String> T = [];

    for (int i = 0; i < list.length && i < 2; i++) {
      if (list[i] != null) {
        if (i == 0) {
          T.add(list[i].replaceAll('_', ' ').toString());
        } else {
          T.add(list[i].replaceAll('_', ' ').toString());
        }
      }
    }
    return T;
  }

  void _onSelectedServices(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userCheckedServices.add(dataName);
      });
    } else {
      setState(() {
        userCheckedServices.remove(dataName);
      });
    }
  }

  AlertDialogUpdate(BuildContext context, onYes) {
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
      content: Text("Are sure you want to update this place information?"),
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


  void updatePlaceDateToFirestore(
      placeId,
      name,
      types,
      lat,
      lng,
      vicinity,
      services,
      hours,
      phone,
      website,
      twitter,
      instagram,
      photos,
      context) async {

    if(placeId.length == 27){
      //googlePlace
    }else{
      var doc = FirebaseFirestore.instance.collection('newPlace').doc(placeId);
      var docRef = await doc.update({
        "Name": "$name",
        "Vicinity": "$vicinity",
        "Address":GeoPoint(lat, lng),
        "Available services": "$services",
        "WorkingHours":"[$hours]",
        "Phone number": "$phone",
        "Website":"$website",
        "Twitter":"$twitter",
        "Instagram":"$instagram",
      });

      print(photos);
      if (photos != null && photos =="[]") {
        var docRef2 = await doc.update({"Photos": "[$photos]"});
        photos = null;
      } else {
        var docRef2 = await doc.update({"Photos": ""});
      }

      Navigator.of(context).pop();

      Fluttertoast.showToast(
        msg: "Place information updated",
        toastLength: Toast.LENGTH_LONG,
      );

    }


  }




}
