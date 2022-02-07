import 'package:focus_spot_finder/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:focus_spot_finder/screens/place_info.dart';
import 'package:flutter/material.dart';

class MarkerService {
  List<Marker> getMarkers(List<Place> places, BuildContext context) {
    List<Marker> markers = [];

    //get the place id and its icon
    places.forEach((place) {
      String placeId = place.placeId;
      Marker marker = Marker(
        markerId: MarkerId(place.name),
        draggable: false,
        icon: place.icon,

        //info that will be displayed in the window when a marker is selected
        infoWindow: InfoWindow(
            title: place.name,
            snippet: place.vicinity,
            onTap: () async {
              Place place = await Place.getPlaceInfo(placeId);
              bool isFav = await Place.checkIfFav(placeId);

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlaceInfo(
                          place: place,
                          isFav: isFav,
                          geo: place.geometry,
                        )),
              );
            }),
        position:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
      );

      markers.add(marker);
    });

    return markers;
  }
}
