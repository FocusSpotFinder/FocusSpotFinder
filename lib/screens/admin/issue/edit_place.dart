import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_app_page.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_bottom_nav.dart';
import 'package:focus_spot_finder/screens/admin/setUp/admin_center_bottom_button.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';
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
  List<String> _types = ['Cafe', 'cafe', 'food', 'Library', 'Book Store', 'Park'];
  List<String> userChecked = [];
  final phoneNumberEditingController = new TextEditingController();
  final vicinityEditingController = new TextEditingController();
  List<String> types = [
    'Cafe', 'Library', 'Book Store', 'Park'
  ];
  List<dynamic> userCheckedTypes = [];
  List<String> _availableServices = [
    "WiFi",
    "Meetings Room",
    "Isolated Capsule",
    "Closed Room",
    "Outdoor Seating",
    "Parkings"
  ];
  List<String> userCheckedServices = [];
  final hoursEditingController = new TextEditingController();
  final websiteEditingController = new TextEditingController();
  final twitterEditingController = new TextEditingController();
  final instagramEditingController = new TextEditingController();
  Set<Marker> _markers = Set();
  double lat;
  double lng;
  final _formKey = GlobalKey<FormState>();
  bool isEnabled = true;
  bool MapDisabled = false;
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

    if(widget.place.placeId.length == 27){
      isEnabled = false;
      MapDisabled = true;
    }

    nameEditingController.text = widget.place.name;
    vicinityEditingController.text = widget.place.vicinity;
    userCheckedTypes = widget.place.types;
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
      enabled: isEnabled,
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

    final vicinityField = TextFormField(
      enabled: isEnabled,
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
      enabled: isEnabled,
      autofocus: false,
      controller: hoursEditingController,
      keyboardType: TextInputType.name,
      validator: (value) {
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
          if (_formKey.currentState.validate()) {
            if (userCheckedTypes.isEmpty) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      scrollable: true,
                      title: Text('Place types',
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.normal,
                            color: Colors.red,
                          )),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Place types cant be left empty",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.red,
                            )
                        ),
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
            } else {
              AlertDialogUpdate(context, () {
                updatePlaceDateToFirestore(
                    widget.place.placeId,
                    nameEditingController.text,
                    userCheckedTypes.toString(),
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

                Navigator.pop(context);

              });
            }
          }
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
        ),
        body:  Stack(
            children: <Widget> [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: SingleChildScrollView(
                      child: Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  height: 15,
                                ),

                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Text("Edit Place",
                                          style: GoogleFonts.lato(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo.shade900,
                                          )),
                                    ]
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 300,
                                        child: Text(
                                            "FSF place can be fully edited.\n"
                                                "Google place (from Places API) data can be partially edited, such as: "
                                                "available services, phone number, website, twitter, instagram and photos.",
                                            style: GoogleFonts.lato(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            )),
                                      )
                                    ]),
                                SizedBox(
                                  height: 30,
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
                                      Text("Types",
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
                                              child: ListView.builder(
                                                  physics: const NeverScrollableScrollPhysics(),

                                                  scrollDirection: Axis.vertical,
                                                  shrinkWrap: true,
                                                  itemCount: types.length,
                                                  itemBuilder: (context, i) {
                                                    return ListTile(
                                                        title: Text(types[i],
                                                            style: GoogleFonts.lato(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.black,
                                                            )),
                                                        trailing: Checkbox(
                                                          value: userCheckedTypes
                                                              .contains(types[i]) || widget.place.types
                                                              .contains(types[i]),
                                                          onChanged: (val) {
                                                            if(isEnabled) {
                                                              _onSelectedTypes(
                                                                  val, types[i]);
                                                            }else{
                                                              null;
                                                            }
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
                                          child: AbsorbPointer(
                                            absorbing: MapDisabled,
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
                                              onTap: (LatLng latLng) async {
                                                _markers.add(
                                                  Marker(
                                                    markerId: MarkerId('mark'),
                                                    position: latLng,
                                                  ),
                                                );
                                                print('${latLng.latitude}, ${latLng.longitude}');
                                                lat = latLng.latitude;
                                                lng = latLng.longitude;
                                                final coordinates = new Coordinates(lat, lng);
                                                var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                                                var first = addresses.first;
                                                vicinityEditingController.text = first.addressLine;
                                                setState(() {});
                                              },
                                            ),
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
                                                              .contains(_availableServices[i]) || widget.place.services
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
                                      Row(
                                          children: [
                                            Text("Working Hours",
                                                style: GoogleFonts.lato(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                )),
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: Text('Working Hours'),
                                                        content: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Text(
                                                              "Working hours should be typed in the following format:\n\nSunday : 09:00 AM - 23:00 PM, \nMonday : 09:00 AM - 23:00 PM, \nTuesday : 09:00 AM - 23:00 PM, \nWednesday : 09:00 AM - 23:00 PM, \nThursday : 09:00 AM - 23:00 PM, \nFriday : 10:00 AM - 23:30 PM, \nSaturday : 10:00 AM - 23:30 PM",
                                                              style: GoogleFonts.lato(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.black,
                                                              )
                                                          ),
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
                                              icon: Icon(Icons.info_outline, color: Colors.grey),
                                            ),
                                          ]
                                      ),


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
                                                  print(widget.place.photos);
                                                  print(e);
                                                  AlertDialogDeletePhoto(context, () {
                                                    Navigator.of(context).pop();
                                                    widget.place.photos.remove(e);
                                                    print(widget.place.photos.length);
                                                    setState(() {});

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
                                ): Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,

                                    children: [
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,

                                          children: [
                                            Text("Photos",
                                                //textAlign: TextAlign.start,
                                                style: GoogleFonts.lato(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                )),
                                          ]
                                      ),
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                                "No photos found\n",
                                                overflow: TextOverflow.ellipsis,
                                                //textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                )),
                                          ]
                                      ),
                                    ]
                                ),


                                SizedBox(
                                  height: 15,
                                ),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Reviews",
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
                                            children: [
                                              (widget.place.reviewsList.isNotEmpty)
                                                  ? Row(
                                                children: [
                                                  new Flexible(
                                                    child: ListView.separated(
                                                        physics: const NeverScrollableScrollPhysics(),
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
                                                              trailing: IconButton(
                                                                  icon: Icon(Icons.delete_outline),
                                                                  color: Colors.red,
                                                                  onPressed: () {
                                                                    AlertDialogDelete(context, ()  {
                                                                      Navigator.of(context).pop();
                                                                      deleteReview(widget.place.reviewsList[index][2]);
                                                                      widget.place.reviewsList.removeAt(index);
                                                                      setState((){});

                                                                      Fluttertoast.showToast(
                                                                        msg: "Review deleted successfully",
                                                                        toastLength: Toast.LENGTH_LONG,
                                                                      );
                                                                    });
                                                                  }),
                                                            ),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              )
                                                  : Text(
                                                "No reviews found\n",
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ]
                                        ),
                                      )
                                    ]
                                ),
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
              )


            ]
        ),

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



  void _onSelectedTypes(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userCheckedTypes.add(dataName);
      });
    } else {
      setState(() {
        userCheckedTypes.remove(dataName);
      });
    }
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
      var doc = FirebaseFirestore.instance.collection('googlePlace').doc(placeId);
      var docRef = await doc.update({
        "Available services": "$services",
        "Phone number": "$phone",
        "Website":"$website",
        "Twitter":"$twitter",
        "Instagram":"$instagram",
      }).catchError((e) async {
        if (e.code == 'not-found') {
          var doc = FirebaseFirestore.instance.collection('googlePlace').doc(placeId);
          var docRef = await doc.set({
            "Available services": "$services",
            "Phone number": "$phone",
            "Website":"$website",
            "Twitter":"$twitter",
            "Instagram":"$instagram",
          });

        }
      });

      if (photos.isNotEmpty) {
        var docRef2 = await doc.update({"Photos": "$photos"});
        photos = null;
      } else {
        var docRef2 = await doc.update({"Photos": ""});
      }


    }else{
      //new place
      var doc = FirebaseFirestore.instance.collection('newPlace').doc(placeId);
      var docRef = await doc.update({
        "Name": "$name",
        "Types": "$types",
        "Vicinity": "$vicinity",
        "Address":GeoPoint(lat, lng),
        "Available services": "$services",
        "Phone number": "$phone",
        "Website":"$website",
        "Twitter":"$twitter",
        "Instagram":"$instagram",
      });
      if (hours != null && hours =="[]") {
        var docRef2 = await doc.update({"WorkingHours": "[$photos]"});
        photos = null;
      } else {
        var docRef2 = await doc.update({"WorkingHours": ""});
      }

      if (photos.isNotEmpty) {
        var docRef2 = await doc.update({"Photos": "$photos"});
        photos = null;
      } else {
        var docRef2 = await doc.update({"Photos": ""});
      }

    }

    Navigator.of(context).pop();

    Fluttertoast.showToast(
      msg: "Place information updated",
      toastLength: Toast.LENGTH_LONG,
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
      content: Text("Are sure you want to delete this review?"),
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

  deleteReview (docId) async {
    FirebaseFirestore.instance.collection('Review').doc(docId).delete();
  }



}