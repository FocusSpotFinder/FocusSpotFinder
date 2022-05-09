import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:focus_spot_finder/Widget/controller.dart';
import 'package:focus_spot_finder/data/data.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/app/chatbot/chatbot_body.dart';
import 'package:focus_spot_finder/services/geolocator_service.dart';
import 'package:focus_spot_finder/services/places_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
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
  var myController = Get.put(MyController());
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  //place data
  String type;
  bool open;
  List<String> services = [];
  String quietRate;
  String foodRate;
  String techRate;

  int numOfMatches = 0; //number of places that matches the user inputs

  @override
  void initState() {
    super.initState();
    //to connect to dialogFlow and authenticate the user
    auth();
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    super.initState();
  }

  auth () async {
    //connect to dialog flow
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
            onPressed: ()  {
              myController.f1 = File('').obs;
              Navigator.of(context).pop();
            },
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
            Expanded(child: ChatbotBody(messages: messages, loggedInUser: loggedInUser,)),
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
                  //text field bar where the user enter input
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

                //send icon
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

  //sends the user and chatbot messages to the screen
  void sendMessage(String text) async {
    //send the user message to the screen and to the chatbot agent
    if (text.isEmpty) return;
    log("User: "+text);
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    //detect if chatbot sent any answer
    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    //send the chatbot message to the user
    if (response.message == null) return;
    setState(() {
      addMessage(response.message);
      log("Chatbot: "+ response.message.text?.text[0]);
    });
  }


  //ads the message to screen
  //do processing for finding workspaces
  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });

    //if the chatbot send a summary for wokspace qualities, start the search
    if(message.text != null && message.text?.text[0].contains("I will find")){
      log("finding workspaces now");

      Future.delayed(Duration(seconds: 4), () {
        setState(() {
          final DialogText text = new DialogText(
              text: ["Finding workspaces for you now!"]);
          Message msg = new Message(text: text);
          addMessage(msg);
        });
      });

      Future.delayed(Duration(seconds: 8), () {
        setState(() {
          final DialogText text2 = new DialogText(text: ["Please wait..."]);
          Message msg2 = new Message(text: text2);
          addMessage(msg2);
        });
      });



      final str = message.text?.text[0];
      getPlaceDate(str);

    }


  }

  getPlaceDate(String str) {
    numOfMatches = 0;
    //type
    final start = 'Type: ';
    final end = ',';

    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end);
    final result = str.substring(startIndex + start.length, endIndex).trim();

    type = result.toString();
    log("***type: "+ type.toString());

    //services
    final start3 = 'Services: ';
    final end3 = ', Quiet:';

    final startIndex3 = str.indexOf(start3);
    final endIndex3 = str.indexOf(end3);
    final result3 = str.substring(startIndex3 + start3.length, endIndex3).trim();

    services = result3.split(' and ');
    log("***services  : "+ services.toString());

    //quiet
    final start5 = 'Quiet: ';
    final end5 = ', Food availability:';

    final startIndex5 = str.indexOf(start5);
    final endIndex5 = str.indexOf(end5);
    final result5 = str.substring(startIndex5 + start5.length, endIndex5).trim();

    quietRate = result5;

    log("***quiet  : "+ quietRate.toString());

    //food
    final start6 = 'Food availability:';
    final end6 = 'and Technical facilities: ';

    final startIndex6 = str.indexOf(start6);
    final endIndex6 = str.indexOf(end6);
    final result6 = str.substring(startIndex6 + start6.length, endIndex6).trim();

    foodRate = result6;

    log("***Food available: "+ foodRate.toString());

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

          for(int j=0 ; j<placesList[i].services.length ; j++) {
            for(int k=0 ; k<services.length; k++){
              if(placesList[i].services[j] == services[k]) {
                //log(placesList[i].services[j]);


                  if(placesList[i].quiet >= 0.5 && (quietRate == "Yes" || quietRate == "It doesnt matter")){

                    if(placesList[i].food >= 0.5 && (foodRate == "Yes" || foodRate == "It doesnt matter")){

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;
                      }else{
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;

                      }

                    }else{

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;

                      }else{
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;

                      }

                    }

                  }else{

                    if(placesList[i].food >= 0.5 && (foodRate == "Yes" || foodRate == "It doesnt matter")){

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;


                      }else{
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;

                      }

                    }else{

                      if(placesList[i].tech >= 0.5 && (techRate == "Yes" || techRate == "It doesnt matter")){
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;

                      }else{
                        setState(() {
                          final CardButton btn = new CardButton (text: "Open",
                              postback: placesList[i].placeId);
                          final List<CardButton> buttons = new List<
                              CardButton>();
                          buttons.add(btn);
                          final DialogCard card = new DialogCard (
                              title: placesList[i].name, buttons: buttons);
                          Message msg = new Message(card: card);
                          addMessage(msg);
                        });
                        numOfMatches++;

                      }

                    }

                  }



              }
            }
          }
        }

        if(numOfMatches == 0){
          setState(() {
            final DialogText text = new DialogText(
                text: ["No workspaces were found that matches your preferences"]);
            Message msg = new Message(text: text);
            addMessage(msg);
          });
          Future.delayed(Duration(seconds: 2), ()
          {
            setState(() {
              final DialogText text = new DialogText(
                  text: [
                    "Would you like to find workspaces again?\n1. Yes\n2. No"
                  ]);
              Message msg = new Message(text: text);
              addMessage(msg);
            });
          });
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

