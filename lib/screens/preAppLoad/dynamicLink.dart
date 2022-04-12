import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DynamicLinkService {

  void handleBackGroundDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((initialLink) {
      print('back initialLink ${initialLink.link.path}');
      print(initialLink?.link);
      if (initialLink != null) {
        handleDLink(initialLink);
      }


    }).onError((error) {
      print(error);
    });

  }

  void handleInitialDeepLink() async {
    final PendingDynamicLinkData initialLink = await FirebaseDynamicLinks.instance.
    getInitialLink();
    print('main initialLink');
    print(initialLink?.link);
    if (initialLink != null) {
      handleDLink(initialLink);
    }
  }

  buildDynamicLink(Uri link)async{
    String i='https://focusspotfinder.page.link';
    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: i,
      link: Uri.parse('https://focusspotfinder.com/story?id=$link'),
      // Android  details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: 'com.example.focus_spot_finder',
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
          bundleId: 'com.FSF.FocusSpotFinder',
          minimumVersion: '2',appStoreId:'1610921701'
      ),
    );
    /*final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl;*/
    return parameters;

  }


  void handleDLink(PendingDynamicLinkData initialLink)async{
    SharedPreferences sharedPreferences= await SharedPreferences.getInstance();
    final Uri deepLink = initialLink.link;
    print(deepLink);

    bool params=deepLink.queryParameters.containsKey('id');
    if(params){
      String param1=deepLink.queryParameters['id'];


      sharedPreferences.setString('dLink', param1);
      print(param1);
      //open placeInfo and send the place by calling getPlace and send the place id
    }

  }
}