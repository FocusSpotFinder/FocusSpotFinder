import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:focus_spot_finder/screens/app/chatbot/chatbot_body.dart';
import 'package:intl/intl.dart';


class Chatbot extends StatefulWidget {

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {

  DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

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
                      color: Colors.cyan.shade100,
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

      if(response.message.text?.text[0].contains("I will find")){
        log("finding workspaces now");
        //DialogPlatform platform = ;

        final DialogText text = new DialogText(text: ["place object"]);
        Message msg = new Message(text: text);
        addMessage(msg);

        //when the user clicks on the card it should open place_info.dart and send the place id
        //final BasicCard  card = new BasicCard(title: "workspace name", subtitle: "workspace type",);
        //Message msg2 = new Message(basicCard: card);
        //addMessage(msg2);


        final str = response.message.text?.text[0];
        getPlaceDate(str);



    }
    });
  }

  getPlaceDate(String str) {
    //type
    final start = 'Type: ';
    final end = ',';

    final startIndex = str.indexOf(start);
    final endIndex = str.indexOf(end);
    final result = str.substring(startIndex + start.length, endIndex).trim();

    log("***type: "+ result.toString());

    //openNow
    final start2 = 'Open now: ';
    final end2 = ', Services:';

    final startIndex2 = str.indexOf(start2);
    final endIndex2 = str.indexOf(end2);
    final result2 = str.substring(startIndex2 + start2.length, endIndex2).trim();

    log("***openNow: "+ result2.toString());

    //services
    final start3 = 'Services: ';
    final end3 = ', Crowded:';

    final startIndex3 = str.indexOf(start3);
    final endIndex3 = str.indexOf(end3);
    final result3 = str.substring(startIndex3 + start3.length, endIndex3).trim();

    log("***services  : "+ result3.toString());

    //crowded
    final start4 = 'Crowded: ';
    final end4 = ', Quiet:';

    final startIndex4 = str.indexOf(start4);
    final endIndex4 = str.indexOf(end4);
    final result4 = str.substring(startIndex4 + start4.length, endIndex4).trim();

    log("***crowded  : "+ result4.toString());

    //quiet
    final start5 = 'Quiet: ';
    final end5 = ', Good food quality:';

    final startIndex5 = str.indexOf(start5);
    final endIndex5 = str.indexOf(end5);
    final result5 = str.substring(startIndex5 + start5.length, endIndex5).trim();

    log("***quiet  : "+ result5.toString());

    //food
    final start6 = 'Good food quality:';
    final end6 = 'and Technical facilities: ';

    final startIndex6 = str.indexOf(start6);
    final endIndex6 = str.indexOf(end6);
    final result6 = str.substring(startIndex6 + start6.length, endIndex6).trim();

    log("***good food : "+ result6.toString());

    //technical
    final start7 = 'Technical facilities: ';
    final end7 = '';

    final startIndex7 = str.indexOf(start7);
    final endIndex7 = str.indexOf(end7);
    final result7 = str.substring(startIndex7 + start7.length, endIndex7).trim();

    log("***technical : "+ result7.toString());
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }

}