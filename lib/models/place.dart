import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/data/data.dart';
import 'package:focus_spot_finder/models/geometry.dart';
import 'package:focus_spot_finder/models/location.dart';
import 'package:focus_spot_finder/models/place_opening_hours.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Place {
  final String placeId;
  final String name;
  final String vicinity;
  final Geometry geometry;
  String phoneNumber;
  String website;
  final List<dynamic> types;
  final BitmapDescriptor icon;
  final List<dynamic> photos;
  final PlaceOpeningHours openingHours;
  String twitter;
  String instagram;
  List<String> services;
  double quiet = 0.0;
  double crowded = 0.0;
  double food = 0.0;
  double tech = 0.0;
  var reviewsList = [];
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  double distance = 0.0;
  bool isOpen = false;
  Place({
    this.placeId,
    this.geometry,
    this.name,
    this.vicinity,
    this.phoneNumber,
    this.website,
    this.types,
    this.photos,
    this.icon,
    this.openingHours,
    this.twitter,
    this.instagram,
    this.quiet,
    this.crowded,
    this.food,
    this.tech,
    this.reviewsList,
    this.services,
  });

  Place.fromJson(Map<dynamic, dynamic> parsedJson, BitmapDescriptor icon)
      : placeId = parsedJson['place_id'],
        name = parsedJson['name'],
        vicinity = parsedJson['vicinity'],
        geometry = Geometry.fromJson(parsedJson['geometry']),
        phoneNumber = (parsedJson['formatted_phone_number'] != null)
            ? parsedJson['formatted_phone_number']
            : null,
        website =
            (parsedJson['website'] != null) ? parsedJson['website'] : null,
        types = (parsedJson['types'] != null) ? parsedJson['types'] : null,
        photos = (parsedJson['photos'] != null) ? parsedJson['photos'] : null,
        openingHours = (parsedJson['opening_hours'] != null)
            ? PlaceOpeningHours.fromJson(parsedJson['opening_hours'])
            : null,
        icon = icon;

  static Future<Place> getPlaceInfo(String placeId) async {
    String placeInfoRequest =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${Data().key}';
    Response placeDetails = await Dio().get(placeInfoRequest);

    //if (placeDetails.data["status"] == "OK") {
    if (placeId.length == 27) {
      log("Google Place");
      if (placeDetails.data["result"] != null) {
        List<String> photoRef = [];
        if (placeDetails.data["result"]["photos"] != null) {
          for (int i = 0; i < placeDetails.data["result"]["photos"].length; i++)
            if (placeDetails.data["result"]["photos"][i]["photo_reference"] !=
                null)
              photoRef.add(
                  placeDetails.data["result"]["photos"][i]["photo_reference"]);
        }
        List<dynamic> photoReference = photoRef;

        String name;
        if (placeDetails.data["result"]["name"] != null) {
          name = placeDetails.data["result"]["name"];
        }

        String vicinity;
        if (placeDetails.data["result"]["vicinity"] != null) {
          vicinity = placeDetails.data["result"]["vicinity"];
        }

        double lat;
        if (placeDetails.data["result"]["geometry"]["location"]["lat"] != null) {
          lat = placeDetails.data["result"]["geometry"]["location"]["lat"];
        }

        double lng;
        if (placeDetails.data["result"]["geometry"]["location"]["lng"] != null) {
          lng = placeDetails.data["result"]["geometry"]["location"]["lng"];
        }

        List<dynamic> types;
        if (placeDetails.data["result"]["types"] != null) {
          types = placeDetails.data["result"]["types"];
        }

        bool openNow = false;
        if (placeDetails.data["result"]["opening_hours"]["open_now"] != null)
          openNow = placeDetails.data["result"]["opening_hours"]["open_now"];

        List<dynamic> workingDays;
        if (placeDetails.data["result"]["opening_hours"]["weekday_text"] !=
            null) {
          workingDays =
              placeDetails.data["result"]["opening_hours"]["weekday_text"];
        }

        Location location = new Location(lat: lat, lng: lng);
        Geometry geometry = new Geometry(location: location);
        PlaceOpeningHours openHours =
            new PlaceOpeningHours(openNow: openNow, workingDays: workingDays);

        //get rate
        double avg = 0.0;
        var quietList = [];
        var crowdedList = [];
        var foodList = [];
        var techList = [];
        double quietAvg = 0.0;
        double crowdedAvg = 0.0;
        double foodAvg = 0.0;
        double techAvg = 0.0;

        // Get docs from collection reference
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('Rate').get();

        // Get data from docs and convert map to List
        final allData = querySnapshot.docs.map((doc) => doc.data()).toList();


        for (int x = 0; x < allData.length; x++) {
          var noteInfo = querySnapshot.docs[x].data() as Map<String, dynamic>;
          if (noteInfo["PlaceId"] == placeId) {
            quietList.add(noteInfo["Quiet"]);
            crowdedList.add(noteInfo["Crowded"]);
            foodList.add(noteInfo["Food quality"]);
            techList.add(noteInfo["Technical facilities"]);
          }
        }

        //quiet
        for (int x = 0; x < quietList.length; x++) {
          quietList[x] = double.parse(quietList[x]);
        }
        for (int i = 0; i < quietList.length; i++) {
          double rate = 0;
          rate = rate + quietList[i];
          avg = rate / quietList.length;
          avg = avg / 3;
          quietAvg = avg;
        }

        //crowded
        for (int x = 0; x < crowdedList.length; x++) {
          crowdedList[x] = double.parse(crowdedList[x]);
        }
        for (int i = 0; i < crowdedList.length; i++) {
          double rate = 0;
          rate = rate + crowdedList[i];
          avg = rate / crowdedList.length;
          avg = avg / 3;
          crowdedAvg = avg;
        }

        //food
        for (int x = 0; x < foodList.length; x++) {
          foodList[x] = double.parse(foodList[x]);
        }
        for (int i = 0; i < foodList.length; i++) {
          double rate = 0;
          rate = rate + foodList[i];
          avg = rate / foodList.length;
          avg = avg / 3;
          foodAvg = avg;
        }

        //tech
        for (int x = 0; x < techList.length; x++) {
          techList[x] = double.parse(techList[x]);
        }
        for (int i = 0; i < techList.length; i++) {
          double rate = 0;
          rate = rate + techList[i];
          avg = rate / techList.length;
          avg = avg / 3;

          techAvg = avg;
        }

        //get reviews
        var reviews = [];
        var reviewsList = [];

        // Get docs from collection reference
        QuerySnapshot querySnapshot2 =
            await FirebaseFirestore.instance.collection('Review').get();

        // Get data from docs and convert map to List
        final allData2 = querySnapshot2.docs.map((doc) => doc.data()).toList();
        var userName;

        for (int x = 0; x < allData2.length; x++) {
          var noteInfo = querySnapshot2.docs[x].data() as Map<String, dynamic>;
          if (noteInfo["PlaceId"] == placeId) {
            String userId = noteInfo["User ID"];
            String docId = querySnapshot2.docs[x].id;

            var collection2 = FirebaseFirestore.instance.collection('Users');
            var docSnapshot2 = await collection2.doc(userId).get();
            if (docSnapshot2.exists) {
              Map<String, dynamic> data = docSnapshot2.data();
              userName = data['name'];
            }

            reviews.add([userName, noteInfo["Review"], docId]);
          }
        }
        reviewsList = reviews;

        //get additional info
        var phone = "";
        var websitee = "";
        var twitter = "";
        var instagram = "";
        var services = "";

        String ph;
        var collection = FirebaseFirestore.instance.collection('googlePlace');
        var docSnapshot = await collection.doc(placeId).get();
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data();
          websitee = data['Website'];
          phone = data['Phone number'];
          twitter = data['Twitter'];
          instagram = data['Instagram'];
          services = data['Available services'];
          ph = data['Photos'];
          print(ph);

         if(ph != ""){
           ph = data['Photos'].replaceAll('[', '').replaceAll(']', '').replaceAll(' ','');
           photoReference = ph.split(',');
         }
         print(photoReference);
        }

        final regExp2= new RegExp(r"(\w+\\?\'?\w*\s?\w+)");
        var servicesList = regExp2
            .allMatches(services)
            .map((m) => m.group(1))
            .map((String item) => item.replaceAll(new RegExp(r'[\[\],]'), ''))
            .map((m) => m)
            .toList();

        Place p = new Place(
          placeId: placeId,
          geometry: geometry,
          name: name,
          vicinity: vicinity,
          phoneNumber: phone,
          website: websitee,
          types: types,
          photos: photoReference,
          openingHours: openHours,
          quiet: quietAvg,
          crowded: crowdedAvg,
          food: foodAvg,
          tech: techAvg,
          reviewsList: reviewsList,
          twitter: twitter,
          instagram: instagram,
          services: servicesList,
        );

        return p;
      }
    } else {
      log("new Place");

      var collection = FirebaseFirestore.instance.collection('newPlace');
      var docSnapshot = await collection.doc(placeId).get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data();
        var name = "";
        if (data['Name'] != null) {
          name = data['Name'];
        }

        var vicinity = "";
        if (data['Vicinity'] != null) {
          vicinity = data['Vicinity'];
        }
        final regExp = new RegExp(r"(\w+\\?\'?\w*\s?\w+)");

        var types = "";
        var typesList = [];
        if (data['Types'] != null) {
          types = data['Types'];
          typesList = regExp
              .allMatches(types)
              .map((m) => m.group(1))
              .map((String item) => item.replaceAll(new RegExp(r'[\[\],]'), ''))
              .map((m) => m)
              .toList();
        }

        String photo = "";
        List<dynamic> photosList = [];

        if (data['Photos'] != "") {
          photo = data['Photos'].replaceAll('[', '').replaceAll(']', '');
          photosList = photo.split(',');
        }

        double lat = 0.0;
        if (data['Address'].latitude != null) {
          lat = data['Address'].latitude;
        }

        double lng = 0.0;
        if (data['Address'].longitude != null) {
          lng = data['Address'].longitude;
        }

        String workingDays = "";
        List<dynamic> workingDaysList = [];
        bool openNow = false;

        if (data['WorkingHours'] != "") {
          workingDays =
              data['WorkingHours'].replaceAll('[', '').replaceAll(']', '');
          workingDaysList = workingDays.split(',');

          var date = DateTime.now();
          var currentDay = DateFormat('EEEE').format(date);
          var currentTime = DateFormat('hh:mm a').format(date);
          var index;

          if (workingDaysList != null && workingDaysList.length == 7) {
            switch (currentDay) {
              case "Sunday":
                index = workingDaysList[0];
                break;
              case "Monday":
                index = workingDaysList[1];
                break;
              case "Tuesday":
                index = workingDaysList[2];
                break;
              case "Wednesday":
                index = workingDaysList[3];
                break;
              case "Thursday":
                index = workingDaysList[4];
                break;
              case "Friday":
                index = workingDaysList[5];
                break;
              case "Saturday":
                index = workingDaysList[6];
                break;
            }
          }

          const ss = ":";
          const es = "-";

          final startIndex = index.indexOf(ss);
          final endIndex = index.indexOf(es, startIndex + ss.length);
          final start2 = index.indexOf(es);

          final startTime = index
              .substring(startIndex + ss.length, endIndex)
              .replaceFirst(" ", "");
          final endTime = index
              .substring(
                start2 + ss.length,
              )
              .replaceFirst(" ", "");

          DateFormat dateFormat = new DateFormat.jm();

          DateTime open = dateFormat.parse(startTime);
          DateTime close = dateFormat.parse(endTime);
          DateTime now = dateFormat.parse(currentTime);

          if (open.isBefore(now) && close.isAfter(now)) {
            openNow = true;
          } else {
            openNow = false;
          }
        }

        Location location = new Location(lat: lat, lng: lng);
        Geometry geometry = new Geometry(location: location);
        PlaceOpeningHours openHours = new PlaceOpeningHours(
            openNow: openNow, workingDays: workingDaysList);

        var twitter = "";
        if (data['Twitter'] != null) {
          twitter = data['Twitter'];
        }

        var instagram = "";
        if (data['Instagram'] != null) {
          instagram = data['Instagram'];
        }

        var websitee = "";
        if (data['Website'] != null) {
          websitee = data['Website'];
        }

        var phone = "";
        if (data['Phone number'] != null) {
          phone = data['Phone number'];
        }

        var services = "";
        List<String> servicesList = [];
        if (data['Available services'] != null) {
          services = data['Available services'];
          servicesList = regExp
              .allMatches(services)
              .map((m) => m.group(1))
              .map((String item) => item.replaceAll(new RegExp(r'[\[\],]'), ''))
              .map((m) => m)
              .toList();
        }

        //get rate
        double avg = 0.0;
        var quietList = [];
        var crowdedList = [];
        var foodList = [];
        var techList = [];
        double quietAvg = 0.0;
        double crowdedAvg = 0.0;
        double foodAvg = 0.0;
        double techAvg = 0.0;

        // Get docs from collection reference
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('Rate').get();

        // Get data from docs and convert map to List
        final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

        for (int x = 0; x < allData.length; x++) {
          var noteInfo = querySnapshot.docs[x].data() as Map<String, dynamic>;
          if (noteInfo["PlaceId"] == placeId) {
            quietList.add(noteInfo["Quiet"]);
            crowdedList.add(noteInfo["Crowded"]);
            foodList.add(noteInfo["Food quality"]);
            techList.add(noteInfo["Technical facilities"]);
          }
        }

        //quiet
        for (int x = 0; x < quietList.length; x++) {
          quietList[x] = double.parse(quietList[x]);
        }
        for (int i = 0; i < quietList.length; i++) {
          double rate = 0;
          rate = rate + quietList[i];
          avg = rate / quietList.length;
          avg = avg / 3;
          quietAvg = avg;
        }

        //crowded
        for (int x = 0; x < crowdedList.length; x++) {
          crowdedList[x] = double.parse(crowdedList[x]);
        }
        for (int i = 0; i < crowdedList.length; i++) {
          double rate = 0;
          rate = rate + crowdedList[i];
          avg = rate / crowdedList.length;
          avg = avg / 3;
          crowdedAvg = avg;
        }

        //food
        for (int x = 0; x < foodList.length; x++) {
          foodList[x] = double.parse(foodList[x]);
        }
        for (int i = 0; i < foodList.length; i++) {
          double rate = 0;
          rate = rate + foodList[i];
          avg = rate / foodList.length;
          avg = avg / 3;
          foodAvg = avg;
        }

        //tech
        for (int x = 0; x < techList.length; x++) {
          techList[x] = double.parse(techList[x]);
        }
        for (int i = 0; i < techList.length; i++) {
          double rate = 0;
          rate = rate + techList[i];
          avg = rate / techList.length;
          avg = avg / 3;

          techAvg = avg;
        }

        //get reviews
        var reviews = [];
        var reviewsList = [];

        // Get docs from collection reference
        QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance.collection('Review').get();

        // Get data from docs and convert map to List
        final allData2 = querySnapshot2.docs.map((doc) => doc.data()).toList();
        var userName;

        for (int x = 0; x < allData2.length; x++) {
          var noteInfo = querySnapshot2.docs[x].data() as Map<String, dynamic>;
          if (noteInfo["PlaceId"] == placeId) {
            String userId = noteInfo["User ID"];
            String docId = querySnapshot2.docs[x].id;


            var collection2 = FirebaseFirestore.instance.collection('Users');
            var docSnapshot2 = await collection2.doc(userId).get();
            if (docSnapshot2.exists) {
              Map<String, dynamic> data = docSnapshot2.data();
              userName = data['name'];
            }

            reviews.add([userName, noteInfo["Review"], docId]);
          }
        }
        reviewsList = reviews;

        Place p = Place(
          placeId: placeId,
          geometry: geometry,
          name: name,
          vicinity: vicinity,
          phoneNumber: phone,
          website: websitee,
          types: typesList,
          photos: photosList,
          openingHours: openHours,
          quiet: quietAvg,
          crowded: crowdedAvg,
          food: foodAvg,
          tech: techAvg,
          reviewsList: reviewsList,
          twitter: twitter,
          instagram: instagram,
          services: servicesList,
        );

        return p;
      } else {
        throw "data doesn't exist";
      }
    }
  }

  //check if the place is in the users favorites collection
  static Future<bool> checkIfFav(placedId) async {
    bool _result = false;
    var user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot _ds = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Favorites')
        .doc(placedId)
        .get();

    if (_ds.exists) {
      _result = true;
    } else {
      _result = false;
    }
    return _result;
  }

  Image getImage(photoReference) {
    photoReference.replaceAll(' ','');

    if (photoReference.contains("firebase")) {
      log("firebase photo");
      return Image.network(
        photoReference,
        fit: BoxFit.fitWidth,
        width: 600,
        height: 200,
      );
    } else {
      final baseUrl = "https://maps.googleapis.com/maps/api/place/photo";
      final maxWidth = "600";
      final maxHeight = "200";
      final url =
          "$baseUrl?maxwidth=$maxWidth&maxheight=$maxHeight&photoreference=$photoReference&key=${Data().key}";
      return Image.network(
        url,
        fit: BoxFit.fitWidth,
        width: 600,
        height: 200,
      );
    }
  }
}
