
import 'package:focus_spot_finder/services/dynamicLink.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:focus_spot_finder/services/marker_service.dart';
import 'package:focus_spot_finder/services/places_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;
//to access the services easily and faster using gat_it library
void setupLocator() {
  locator.registerLazySingleton(() => GeoLocatorService());
  locator.registerLazySingleton(() => MarkerService());
  locator.registerLazySingleton(() => PlacesService());
  locator.registerLazySingleton(() => DynamicLinkService());
}
