import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Data {
  Data._();
  static Data _instance = Data._();
  factory Data() => _instance;
  final String key = 'AIzaSyACWoXHs--vIWycphQcc-infujRMkMlS08';

  BitmapDescriptor icon;

  Future<void> init(BuildContext context) async {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    icon = await BitmapDescriptor.fromAssetImage(
        configuration, 'assets/marker.png');
  }
}
