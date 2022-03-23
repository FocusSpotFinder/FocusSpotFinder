import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/providers/places_provider.dart';
import 'package:focus_spot_finder/screens/addPlace/add_place_rate_review.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:geocoder/geocoder.dart';

class AddPlacelocationPicker extends HookConsumer {
  final String docId;
  AddPlacelocationPicker({@required this.docId});

  @override
  Widget build(BuildContext context, ref) {
    final currentPosition = ref.watch(placesProvider).currentPosition;

    final ValueNotifier<double> lat = useState(0.0);
    final ValueNotifier<double> lng = useState(0.0);
    final ValueNotifier<Set<Marker>> _markers = useState(Set());

    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
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
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final coordinates = new Coordinates(lat.value, lng.value);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);
          var first = addresses.first;
          print(" ${first.addressLine} ");

          alertDialogAddPlaceLocation(context, () {
            postPlaceDateToFirestoreGoemetry(
                lat.value, lng.value, first.addressLine, docId, context);
          });
        },
        child: Icon(
          Icons.add_location_rounded,
          color: Colors.white,
          size: 30,
        ),
        backgroundColor: Colors.cyan.shade100,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void postPlaceDateToFirestoreGoemetry(
      double lat, double lng, String vicinity, String docId, context) async {
    var doc = FirebaseFirestore.instance.collection('newPlace').doc(docId);
    await doc.update({"Address": GeoPoint(lat, lng), "Vicinity": "$vicinity"});
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPlaceRateReview(docId: docId)));
  }

  alertDialogAddPlaceLocation(BuildContext context, onYes) {
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
      content: Text("Are sure of the place location?"),
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
}
