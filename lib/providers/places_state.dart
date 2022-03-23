import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import 'package:focus_spot_finder/models/place.dart';

class PlacesState extends Equatable {
  final bool loading;
  final List<Place> nearbyPlaces;
  final Position currentPosition;

  PlacesState(
    this.loading,
    this.nearbyPlaces,
    this.currentPosition,
  );

  @override
  List<Object> get props => [loading, nearbyPlaces, currentPosition];

  PlacesState copyWith({
    bool loading,
    List<Place> nearbyPlaces,
    Position currentPosition,
  }) {
    return PlacesState(
      loading ?? this.loading,
      nearbyPlaces ?? this.nearbyPlaces,
      currentPosition ?? this.currentPosition,
    );
  }

  @override
  String toString() =>
      'PlacesState(loading: $loading, nearbyPlaces: $nearbyPlaces, currentPosition: $currentPosition)';
}
