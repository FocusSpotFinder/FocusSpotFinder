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
  String quietRate;
  String crowdedRate;
  String foodRate;
  String techRate;


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
            SizedBox(
              height: 25,
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

      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          final DialogText text = new DialogText(
              text: ["Finding workspaces for you now!"]);
          Message msg = new Message(text: text);
          addMessage(msg);
        });
      });

      Future.delayed(Duration(seconds: 7), () {
        setState(() {
          final DialogText text2 = new DialogText(text: ["Please wait..."]);
          Message msg2 = new Message(text: text2);
          addMessage(msg2);
        });
      });



      final str = message.text?.text[0];
      getPlaceDate(str);

      /*final DialogText text3 = new DialogText(text: ["place object"]);
      Message msg3 = new Message(text: text3);
      addMessage(msg3);*/

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

    crowdedRate = result4;

    log("***crowded  : "+ crowdedRate.toString());

    //quiet
    final start5 = 'Quiet: ';
    final end5 = ', Good food quality:';

    final startIndex5 = str.indexOf(start5);
    final endIndex5 = str.indexOf(end5);
    final result5 = str.substring(startIndex5 + start5.length, endIndex5).trim();

    quietRate = result5;

    log("***quiet  : "+ quietRate.toString());

    //food
    final start6 = 'Good food quality:';
    final end6 = 'and Technical facilities: ';

    final startIndex6 = str.indexOf(start6);
    final endIndex6 = str.indexOf(end6);
    final result6 = str.substring(startIndex6 + start6.length, endIndex6).trim();

    foodRate = result6;

    log("***good food : "+ foodRate.toString());

    //technical
    final start7 = 'and Technical facilities: ';

    final startIndex7 = str.indexOf(start7);
    final result7 = str.substring(startIndex7 + start7.length,).trim();

    techRate = result7;

    log("***technical : "+ techRate.toString());


    Permission.locationWhenInUse.request().then((value) async {
      Logger().i(value);
      if (value.isGranted) {
        Position position = await locatorService.getLocation();
        List<Place> placesList = await placesService.getPlacesChatbot(position.latitude, position.longitude, Data().icon, type.toLowerCase() );

        log(placesList.length.toString());
        for(int i =0 ; i<placesList.length; i++){
          //log(placesList[i].placeId);

          //if(placesList[i].openingHours.openNow != null && placesList[i].openingHours.openNow == open){
          //log("open");
          for(int j=0 ; j<placesList[i].services.length ; j++) {
            for(int k=0 ; k<services.length; k++){
              if(placesList[i].services[j] == services[k]) {
                //log(placesList[i].services[j]);

                if(placesList[i].crowded >= 0.5 && (crowdedRate == "Yes" || crowdedRate == "It doesnt matter")){

                  if(placesList[i].quiet >= 0.5 && (quietRate == "Yes" || quietRate == "It doesnt matter")){

                    if(placesList[i].food >= 0.5 && (foodRate == "Yes" || foodRate == "It doesnt matter")){

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }else{

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }

                  }else{

                    if(placesList[i].food >= 0.5 && (foodRate == "Yes" || foodRate == "It doesnt matter")){

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");


                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }else{

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }

                  }

                }else{

                  if(placesList[i].quiet >= 0.5 && (quietRate == "Yes" || quietRate == "It doesnt matter")){

                    if(placesList[i].food >= 0.5 && (foodRate == "Yes" || foodRate == "It doesnt matter")){

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }else{

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }

                  }else{

                    if(placesList[i].food >= 0.5 && (foodRate == "Yes" || foodRate == "It doesnt matter")){

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }else{

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }else{
                        setState(() {
                          final DialogText text = new DialogText(
                              text: [placesList[i].name]);
                          Message msg = new Message(text: text);
                          addMessage(msg);
                        });
                        log("place found");

                      }

                    }

                  }

                }

              }
            }
          }
          // }
        }

      }
      else {
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

