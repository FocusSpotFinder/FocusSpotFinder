import 'package:flutter/widgets.dart';
import 'package:focus_spot_finder/data/data.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/providers/places_state.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:focus_spot_finder/services/places_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final placesProvider = StateNotifierProvider<PlacesNotifier, PlacesState>((ref) {
  return PlacesNotifier();
});

class PlacesNotifier extends StateNotifier<PlacesState> {
  PlacesNotifier() : super(PlacesState(false, [], null));
  final placesService = PlacesService();
  final locatorService = GeoLocatorService();

  //first make the places state loading
  //then load the current location
  //then load placed
  Future<void> init(BuildContext context) async {
    state = state.copyWith(loading: true);
    await loadCurrentLocation();
    await Data().init(context);
    await loadPlaces();
    state = state.copyWith(loading: false);
  }

  //load the places
  Future<void> loadPlaces() async {
    if (!state.loading) {state = state.copyWith(loading: true);
      //request the places from the places_service and send the user location
    //the location is stored in the places state
      final data = await placesService.getPlaces(state.currentPosition.latitude,
          state.currentPosition.longitude, Data().icon);

      //measure the distance for each place from the user location
      for (Place place in data) {
        place.distance = locatorService.getDistance(
            state.currentPosition.latitude,
            state.currentPosition.longitude,
            place.geometry.location.lat,
            place.geometry.location.lng);

        //if place openNow variable is null then assign false
        place.isOpen = place.openingHours?.openNow ?? false;
      }

      //assign the places into two lists. open and closed
      final openPlaces = data.where((element) => element.isOpen).toList();
      final closedPlaces = data.where((element) => !element.isOpen).toList();

      //sort the open and closed places based on the distance
      openPlaces.sort((a, b) => a.distance.compareTo(b.distance));
      closedPlaces.sort((a, b) => a.distance.compareTo(b.distance));

      //combine the twolists
      final sortedList = openPlaces + closedPlaces;

      try {
        final x = sortedList
            .map((e) => "${e.distance} and ${e.openingHours?.openNow ?? false}")
            .toList();

        Logger().i(x);
      } catch (e) {
        Logger().e(e);
      }

      state = state.copyWith(nearbyPlaces: sortedList, loading: false);
    }
  }

  //get the location the user and assign it in the places state
  Future<void> loadCurrentLocation() async {
    final data = await locatorService.getLocation();
    state = state.copyWith(currentPosition: data);
  }
}
