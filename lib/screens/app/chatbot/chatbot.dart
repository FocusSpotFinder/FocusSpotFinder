import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:focus_spot_finder/data/data.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/screens/app/chatbot/chatbot_body.dart';
import 'package:focus_spot_finder/screens/preAppLoad/permission_screen.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:focus_spot_finder/services/places_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';


class Chatbot extends StatefulWidget {

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {

  DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  final locatorService = GeoLocatorService();
  final placesService = PlacesService();

  //place date
  String type;
  bool open;
  List<String> services = [];
  double quiet = 0.0;
  double crowded = 0.0;
  double food = 0.0;
  double tech = 0.0;


  @override
  void initState() {
    super.initState();
    auth();
  }

  auth () async {
    DialogAuthCredentials credentials = await DialogAuthCredentials.fromFile("assets/service.json");
    DialogFlowtter instance = DialogFlowtter(credentials: credentials,);
    dialogFlowtter = instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.cyan.shade100,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 30),
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          toolbarHeight: 55,
          title:Row (
            children: [
              CircleAvatar(
                backgroundImage: AssetImage("assets/chatbot.png"),
                backgroundColor: Colors.cyan.shade100,

              ),
              Text("Chatbot", textAlign: TextAlign.center,)

            ],
          )
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 10),
              child: Text("Today, ${DateFormat("Hm").format(DateTime.now())}", style: TextStyle(
                  fontSize: 20
                  , color: Colors.black38
              ),),
            ),
            //get the chatbot body from the class chatbot_body.dart
            Expanded(child: ChatbotBody(messages: messages)),
            Container(
              child: ListTile(

                title: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(
                        15)),
                    color: Color.fromRGBO(220, 220, 220, 1),
                  ),
                  padding: EdgeInsets.only(left: 15),
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter a Message...",
                      hintStyle: TextStyle(
                          color: Colors.black26
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),

                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),
                    onChanged: (value) {

                    },
                  ),
                ),

                trailing: IconButton(

                    icon: Icon(
                      Icons.send,
                      size: 30.0,
                      color: Colors.indigo,
                    ),
                    onPressed: () {

                      if (_controller.text.isEmpty) {
                        print("empty message");
                      } else {
                        sendMessage(_controller.text);
                        _controller.clear();
                      }
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    }),

              ),

            ),

          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    log("User: "+text);
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    if (response.message == null) return;

    setState(() {
      addMessage(response.message);
      log("Chatbot: "+ response.message.text?.text[0]);
    });

  }


  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });

    if(message.text?.text[0].contains("I will find")){
      log("finding workspaces now");

      final DialogText text = new DialogText(text: ["Finding workspaces for you now!"]);
      Message msg = new Message(text: text);
      addMessage(msg);

      final DialogText text2 = new DialogText(text: ["Please wait..."]);
      Message msg2 = new Message(text: text2);
      addMessage(msg2);

      final str = message.text?.text[0];
      getPlaceDate(str);

      final DialogText text3 = new DialogText(text: ["place object"]);
      Message msg3 = new Message(text: text3);
      addMessage(msg3);

      //when the user clicks on the card it should open place_info.dart and send the place id
      //final BasicCard  card = new BasicCard(title: "workspace name", subtitle: "workspace type",);
      //Message msg2 = new Message(basicCard: card);
      //addMessage(msg2);


    }


  }

  getPlaceDate(String str) {
    //type
    final start = 'Type: ';
    final end = ',';

    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end);
    final result = str.substring(startIndex + start.length, endIndex).trim();

    type = result.toString();
    log("***type: "+ type.toString());

    //openNow
    final start2 = 'Open now: ';
    final end2 = ', Services:';

    final startIndex2 = str.indexOf(start2);
    final endIndex2 = str.indexOf(end2);
    var result2 = str.substring(startIndex2 + start2.length, endIndex2).trim();

    open = parseBool(result2);
    log("***openNow: "+ open.toString());

    //services
    final start3 = 'Services: ';
    final end3 = ', Crowded:';

    final startIndex3 = str.indexOf(start3);
    final endIndex3 = str.indexOf(end3);
    final result3 = str.substring(startIndex3 + start3.length, endIndex3).trim();

    services = result3.split(' and ');
    log("***services  : "+ services.toString());

    //crowded
    final start4 = 'Crowded: ';
    final end4 = ', Quiet:';

    final startIndex4 = str.indexOf(start4);
    final endIndex4 = str.indexOf(end4);
    final result4 = str.substring(startIndex4 + start4.length, endIndex4).trim();

    if(result4.toString() == "Yes"){
      crowded = 0.1;
    }else if(result4.toString() == "It doesnt matter"){
      crowded = 0.0;
    }else if(result4.toString() == "No"){
      crowded = 0.33;
    }
    log("***crowded  : "+ crowded.toString());

    //quiet
    final start5 = 'Quiet: ';
    final end5 = ', Good food quality:';

    final startIndex5 = str.indexOf(start5);
    final endIndex5 = str.indexOf(end5);
    final result5 = str.substring(startIndex5 + start5.length, endIndex5).trim();

    if(result5.toString() == "Yes"){
      quiet = 0.33;
    }else if(result5.toString() == "It doesnt matter"){
      quiet = 0.0;
    }else if(result5.toString() == "No"){
      quiet = 0.1;
    }
    log("***quiet  : "+ quiet.toString());

    //food
    final start6 = 'Good food quality:';
    final end6 = 'and Technical facilities: ';

    final startIndex6 = str.indexOf(start6);
    final endIndex6 = str.indexOf(end6);
    final result6 = str.substring(startIndex6 + start6.length, endIndex6).trim();

    if(result6.toString() == "Yes"){
      food = 0.1;
    }else if(result6.toString() == "It doesnt matter"){
      food = 0.0;
    }else if(result6.toString() == "No"){
      food = 0.33;
    }
    log("***good food : "+ food.toString());

    //technical
    final start7 = 'and Technical facilities: ';

    final startIndex7 = str.indexOf(start7);
    final result7 = str.substring(startIndex7 + start7.length,).trim();
    if(result7.toString() == "Yes"){
      tech = 0.1;
    }else if(result7.toString() == "It doesnt matter"){
      tech = 0.0;
    }else if(result7.toString() == "No"){
      tech = 0.33;
    }
    log("***technical : "+ tech.toString());


    Permission.locationWhenInUse.request().then((value) async {
      Logger().i(value);
      if (value.isGranted) {
        Position position = await locatorService.getLocation();
        List<Place> placesList = await placesService.getPlacesChatbot(position.latitude, position.longitude, Data().icon, type.toLowerCase() );

        log(placesList.length.toString());
        for(int i=0; i<placesList.length; i++){
          log(placesList[i].placeId);
        }
        /*for(int i=0 ; i<placesList.length ; i++){
          /*if(placesList[i].types.toString().toLowerCase().contains(type.toLowerCase())) {
            log("found match place type "+placesList[i].name);
          }*/
          log(placesList[i].placeId);
          if(placesList[i].openingHours.openNow == open){
            log("found match opening hours "+placesList[i].name);
          }

          /*for(int j=0 ; j<placesList[i].services.length ; j++) {
            for(int k=0 ; k<services.length ; k++){
              if (placesList[i].services[j].toLowerCase() == services[k].toLowerCase()) {
                log("matched services" + services[k]);
              }
            }
          }*/


        }

         */


      } else {
        final DialogText text2 = new DialogText(text: ["Please enable your location permission, so I can find workspaces for you!"]);
        Message msg2 = new Message(text: text2);
        addMessage(msg2);      }
    }
    );

  }

  bool parseBool(String open) {
    if(open.toLowerCase() == 'true' || open.toLowerCase() == 'yes'){
      return true;
    }else{
      return false;
    }
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }

}