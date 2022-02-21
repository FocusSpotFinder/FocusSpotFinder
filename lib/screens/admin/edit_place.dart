import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/issue.dart';
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
    "Isolated Capsule Room",
    "Closed Room",
    "Outdoor Seating"
  ];
  List<String> userCheckedServices = [];
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
    phoneNumberEditingController.text = widget.place.phoneNumber;
    websiteEditingController.text = widget.place.website;
    twitterEditingController.text = widget.place.twitter;
    instagramEditingController.text = widget.place.instagram;
    lat = widget.place.geometry.location.lat;
    lng = widget.place.geometry.location.lng;

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

                            Container(
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
                                tiltGesturesEnabled: false,
                                onTap: (LatLng latLng) {
                                  _markers
                                      .add(Marker(markerId: MarkerId('mark'), position: latLng));
                                  print('${latLng.latitude}, ${latLng.longitude}');
                                  lat = latLng.latitude;
                                  lng = latLng.longitude;
                                  setState(() {});
                                },
                                markers: Set<Marker>.of(_markers),
                              ),
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

  AlertDialogDelete(BuildContext context, onYes) {
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
      content: Text("Are sure you want to delete this place?"),
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


  /*alertMap() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Place Location",
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
                      child: Container(
                        height:200.
                        width: MediaQuery.of(context).size.width,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target:
                              LatLng(currentPosition.latitude, currentPosition.longitude),
                              zoom: 16.0),
                          zoomGesturesEnabled: true,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          compassEnabled: true,
                          tiltGesturesEnabled: false,
                          onTap: (LatLng latLng) {
                            _markers.value
                                .add(Marker(markerId: MarkerId('mark'), position: latLng));
                            print('${latLng.latitude}, ${latLng.longitude}');
                            lat.value = latLng.latitude;
                            lng.value = latLng.longitude;
                          },
                          markers: Set<Marker>.of(_markers.value),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: 36,
                          width: 85,
                          child: ElevatedButton(
                              child: Text("Submit"),
                              onPressed: () {

                              })
                      ),
                    ])
              ],
            );
          },
        );
      },
    );
  }

*/


}
