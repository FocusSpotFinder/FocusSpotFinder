import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:focus_spot_finder/screens/preAppLoad/splash_screen.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../models/place.dart';
import '../../../providers/places_provider.dart';
import 'home.dart';
import 'place_info.dart';
import '../../../services/marker_service.dart';

class HomeBody extends HookConsumerWidget {
  HomeBody({Key key}) : super(key: key);

  final geoService = GeoLocatorService();
  final markerService = MarkerService();

  @override
  Widget build(BuildContext context, ref) {
    final ValueNotifier<String> search = useState('');
    final state = ref.watch(placesProvider);
    final ValueNotifier<bool> isClicked = useState(false);
    return VisibilityDetector(
      key: Key('Home'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction.toInt() == 1) {
          Logger().i(info.visibleFraction);
          ref.read(placesProvider.notifier).loadPlaces();
        }
      },
      child: Stack(
        children: [
          (state.currentPosition != null)
              ? Column(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(state.currentPosition.latitude,
                                state.currentPosition.longitude),
                            zoom: 16.0),
                        zoomGesturesEnabled: true,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        markers: Set<Marker>.of(markerService.getMarkers(
                            state.nearbyPlaces, context)),
                      ),
                    ),
                    SizedBox(
                      //to put space between the list and the map
                      height: 5.0,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: TextField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.search),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.indigo, width: 0.3),
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.cyan, width: 0.1),
                          ),
                        ),
                        onChanged: (value) {
                          search.value = value;
                        },
                      ),
                    ),
                    state.loading
                        ? LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.cyan.shade100),
                          )
                        : SizedBox(
                            //to put space between the list and the map
                            height: 4.0,
                          ),
                    Expanded(
                      child: (state.nearbyPlaces.length > 0)
                          ? ListView.builder(
                              itemCount: state.nearbyPlaces.length,
                              itemBuilder: (context, index) {
                                if (search != null &&
                                    !state.nearbyPlaces[index].name
                                        .toLowerCase()
                                        .contains(search.value.toLowerCase())) {
                                  return SizedBox();
                                }

                                return Card(
                                  child: ListTile(
                                    title: Text(state.nearbyPlaces[index].name),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 3.0,
                                        ),
                                        (state.nearbyPlaces[index].types !=
                                                null)
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: typeFormat(state
                                                    .nearbyPlaces[index].types))
                                            : Row(),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Builder(builder: (context) {
                                          return Text(
                                              '${state.nearbyPlaces[index].vicinity} \u00b7 ${state.nearbyPlaces[index].isOpen ? 'Open' : 'Close'} \u00b7 ${(state.nearbyPlaces[index].distance / 1000).round()} km');
                                        })
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.directions),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () {
                                        alertDialogGoogleNav(context, () {
                                          geoService.openMap(
                                              state.nearbyPlaces[index].geometry
                                                  .location.lat,
                                              state.nearbyPlaces[index].geometry
                                                  .location.lng);
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                    onTap: () async {
                                      Place place = await Place.getPlaceInfo(
                                          state.nearbyPlaces[index].placeId);
                                      bool isFav = await Place.checkIfFav(
                                          state.nearbyPlaces[index].placeId);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlaceInfo(
                                            place: place,
                                            isFav: isFav,
                                            geo: state
                                                .nearbyPlaces[index].geometry,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text('No Places Found Nearby'),
                            ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      //CircularProgressIndicator(),
                      Icon(
                        Icons.warning_amber,
                        color: Colors.red,
                        size: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "The application needs to access your location, to be able to list workspaces around you",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: StadiumBorder(), primary: Colors.cyan.shade100),
                          onPressed: () async {
                            // await OpenAppSettings.openAppSettings();
                            Logger().i(await Permission.locationWhenInUse.status);
                            if (await Permission.locationWhenInUse
                                .request()
                                .then((value) => value.isGranted)) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SplashScreen()));
                            } else {
                              Logger().i("opening setting");
                              openAppSettings();
                            }
                          },
                          child: Text('Allow Permission')
                      ),
                    ]
                  ),
                ),
          isClicked.value
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black45,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
