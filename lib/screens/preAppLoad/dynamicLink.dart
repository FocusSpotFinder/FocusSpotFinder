import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DynamicLinkService {

  void handleBackGroundDynamicLinks() async {
    ///To bring INTO FOREGROUND FROM DYNAMIC LINK.
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
  // bool _deeplink = true;
  void handleInitialDeepLink() async {
    final PendingDynamicLinkData initialLink = await FirebaseDynamicLinks.instance.
    getInitialLink();
    // getDynamicLink(Uri.parse(link));
    print('main initialLink');
    print(initialLink?.link);
    if (initialLink != null) {
      handleDLink(initialLink);
    }
    // Example of using the dynamic link to push the user to a different screen
    // Navigator.pushNamed(context, deepLink.path);
  }

  buildDynamicLink(Uri link)async{
    String i='https://focusspotfinder.page.link';
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      // The Dynamic Link URI domain. You can view created URIs on your Firebase console
      uriPrefix: i,
      // The deep Link passed to your application which you can use to affect change
      link: Uri.parse('https://focusspotfinder.com/story?id=$link'),
      // Android application details needed for opening correct app on device/Play Store
      androidParameters: const AndroidParameters(
        packageName: 'com.example.focus_spot_finder',
        minimumVersion: 1,
      ),
      // iOS application details needed for opening correct app on device/App Store
      iosParameters: const IOSParameters(
          bundleId: 'com.fsf.focusSpotFinder',
          minimumVersion: '2',appStoreId:'1610921701'
      ),
    );
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
    }

  }
}