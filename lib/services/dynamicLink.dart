import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DynamicLinkService {

  //handles links in background
  void handleBackGroundDynamicLinks() async {
    //listens if there is a link sent
    FirebaseDynamicLinks.instance.onLink.listen((initialLink) {
      print(initialLink?.link);
      //if there is a link sent, handle the deep link by calling the method
      if (initialLink != null) {
        handleDLink(initialLink);
      }


    }).onError((error) {
      print(error);
    });

  }

  //handles the link that will be sent when the app opens
  void handleInitialDeepLink() async {
    final PendingDynamicLinkData initialLink = await FirebaseDynamicLinks.instance.getInitialLink(); //get the initial link
    print('main initialLink');
    print(initialLink?.link);
    //if the link was null, ignore. otherwise call the method handleDLink
    if (initialLink != null) {
      handleDLink(initialLink);
    }
  }

  //builds a dynamic (share) link that will be sent to the user
  buildDynamicLink(Uri link)async{
    String i='https://focusspotfinder.page.link'; //link to the application website
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
    return parameters;
  }


  //handles deep links, extract the placeId from the link and store it
  void handleDLink(PendingDynamicLinkData initialLink)async{
    SharedPreferences sharedPreferences= await SharedPreferences.getInstance(); //used to store preferences
    final Uri deepLink = initialLink.link; //extract the link
    print(deepLink);

    bool params=deepLink.queryParameters.containsKey('id'); //check if there is a placeId in the link

    //if the link contains placeId
    if(params){
      String param1=deepLink.queryParameters['id']; //get the placeId from the link
      sharedPreferences.setString('dLink', param1);//set the placeId in the shared preferences
      print(param1);
    }

  }

}