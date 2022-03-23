import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final loactionProvider = FutureProvider<Position>((ref) async {
  final locatorService = GeoLocatorService();
  return await locatorService.getLocation();
});
