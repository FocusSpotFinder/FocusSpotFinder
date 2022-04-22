import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/app/home/place_info.dart';

class ChatbotBody extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  const ChatbotBody({Key key, this.messages = const [],}) : super(key: key);

  @override
  State<ChatbotBody> createState() => _ChatbotBodyState();
}
User user = FirebaseAuth.instance.currentUser;
UserModel loggedInUser = UserModel();

class _ChatbotBodyState extends State<ChatbotBody> {

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, i) {
        var obj = widget.messages[widget.messages.length - 1 - i];
        Message message = obj['message'];
        bool isUserMessage = obj['isUserMessage'] ?? false;
        return Row(
          mainAxisAlignment:
          isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageContainer(
              message: message,
              isUserMessage: isUserMessage,
            ),
          ],
        );
      },
      separatorBuilder: (_, i) => Container(height: 10),
      itemCount: widget.messages.length,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final Message message;
  final bool isUserMessage;


  const _MessageContainer({
    Key key,
    this.message,
    this.isUserMessage = false,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {

    return Container(

      padding: EdgeInsets.only(left: 10, right: 10),

      child: Row(
        mainAxisAlignment: !isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [

          !isUserMessage ? Container(
            color: Colors.white,
            height: 50,
            width: 50,
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/chatbot.png"),
              backgroundColor: Colors.transparent,


            ),
          ) : Container(),

          (message.text != null)?
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Bubble(
                radius: Radius.circular(15.0),
                color: !isUserMessage ? Colors.indigo : Colors.cyan,
                elevation: 0.0,

                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[

                      SizedBox(
                        width: 10.0,
                      ),
                      Flexible(
                          child: Container(
                            constraints: BoxConstraints( maxWidth: 200),
                            child: (isUserMessage)?  Text(
                              message.text?.text[0] ?? '',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ) : Text(
                              message.text?.text[0] ?? '',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ))
                    ],
                  ),
                )),
          ):  _CardContainer(card: message.card),



          isUserMessage? Container(
              height: 50,
              width: 50,
              child:(loggedInUser.profileImage !=
                  null &&
                  loggedInUser
                      .profileImage.isNotEmpty)
                  ? CircleAvatar(
                backgroundColor:
                Colors.transparent,
                radius: MediaQuery.of(context)
                    .size
                    .height *
                    0.1,
                backgroundImage: NetworkImage(
                    loggedInUser
                        .profileImage),
              )
                  : CircleAvatar(
                  backgroundColor:
                  Colors.transparent,
                  radius: MediaQuery.of(context)
                      .size
                      .height *
                      0.1,
                  backgroundImage: AssetImage(
                    'assets/place_holder.png',
                  ))
          ) : Container(),

        ],
      ),
    );



  }
}



class _CardContainer extends StatelessWidget {
  final DialogCard card;

  const _CardContainer({
    Key key,
    this.card,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Padding(
        padding: EdgeInsets.all(5.0),
    child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: Colors.indigo,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.imageUri != null)
              Container(
                constraints: BoxConstraints.expand(height: 150),
                child: Image.network(
                  card.imageUri,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.fromLTRB(0,0,5,0),
                      child: Text(
                    card.title ?? '',
                    textAlign: TextAlign.left,

                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                  ),
                  if (card.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        card.subtitle,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  if (card.buttons?.isNotEmpty ?? false)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 40,
                      ),
                      child: Container(
                          width: 100,
                          alignment: Alignment.center,
                          child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.indigo,
                          backgroundColor: Colors.white,

                        ),
                        child: Text(card.buttons[0].text ?? ''),
                        onPressed: () async {

                          String placeId = card.buttons[0].postback;
                          Place place = await Place.getPlaceInfo(placeId);
                          bool isFav = await Place.checkIfFav(placeId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlaceInfo(
                                  place: place,
                                  isFav: isFav,
                                  geo: place.geometry,
                                )),
                          );
                        },
                      )

    )
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }


}
