import 'package:flutter/widgets.dart';
import 'package:focus_spot_finder/data/data.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/providers/places_state.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:focus_spot_finder/services/places_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final placesProvider =
    StateNotifierProvider<PlacesNotifier, PlacesState>((ref) {
  return PlacesNotifier();
});

class PlacesNotifier extends StateNotifier<PlacesState> {
  PlacesNotifier() : super(PlacesState(false, [], null));
  final placesService = PlacesService(); //i
  final locatorService = GeoLocatorService();

  Future<void> init(BuildContext context) async {
    state = state.copyWith(loading: true);

    await loadCurrentLocation();
    await Data().init(context);
    await loadPlaces();
    state = state.copyWith(loading: false);
  }

  Future<void> loadPlaces() async {
    if (!state.loading) {
      state = state.copyWith(loading: true);
      final data = await placesService.getPlaces(state.currentPosition.latitude,
          state.currentPosition.longitude, Data().icon);

      for (Place place in data) {
        place.distance = locatorService.getDistance(
            state.currentPosition.latitude,
            state.currentPosition.longitude,
            place.geometry.location.lat,
            place.geometry.location.lng);

        place.isOpen = place.openingHours?.openNow ?? false;
      }

      final openPlaces = data.where((element) => element.isOpen).toList();
      final closedPlaces = data.where((element) => !element.isOpen).toList();

      openPlaces.sort((a, b) => a.distance.compareTo(b.distance));
      closedPlaces.sort((a, b) => a.distance.compareTo(b.distance));
      final sortedList = openPlaces + closedPlaces;
      // data.sort((a, b) {
      //   final int x = a.isOpen ? 0 : 1;
      //   final int y = b.isOpen ? 0 : 1;
      //   return x.compareTo(y);
      // });
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

  Future<void> loadCurrentLocation() async {
    final data = await locatorService.getLocation();
    state = state.copyWith(currentPosition: data);
  }
}
