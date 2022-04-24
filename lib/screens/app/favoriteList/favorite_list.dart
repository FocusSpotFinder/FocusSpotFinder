import 'package:flutter/material.dart';
import 'package:focus_spot_finder/models/favorite_list_model.dart';
import 'package:focus_spot_finder/models/user_model.dart';
import 'package:focus_spot_finder/screens/app/home/place_info.dart';
import 'package:focus_spot_finder/models/place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focus_spot_finder/services/dynamicLink.dart';

class FavList extends StatefulWidget {
  final void Function() onBackPress;

  const FavList({Key key, @required this.onBackPress}) : super(key: key);

  @override
  State<FavList> createState() => _FavListState();
}

class _FavListState extends State<FavList> {
  bool isClicked = false;
  User user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  final favoriteList = FavoriteListModel();

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackPress();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan.shade100,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: 30),
            tooltip: 'Back',
            onPressed: widget.onBackPress,
          ),
          toolbarHeight: 55,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: favoriteList.readItems(), //call this to load the places from firebase
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            } else if (snapshot.hasData || snapshot.data != null) {
              return ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 7.0),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  var noteInfo = snapshot.data.docs[index].data() as Map<String, dynamic>;
                  //get the values
                  String placeId = noteInfo['placeId'];
                  String name = noteInfo['name'];
                  String vicinity = noteInfo['vicinity'];
                  List<dynamic> types = noteInfo['types'];
                  DynamicLinkService().handleBackGroundDynamicLinks();

                  return Ink(
                    decoration: BoxDecoration(
                      color: Colors.cyan.shade50,
                    ),
                    child: ListTile(
                        isThreeLine: true,
                        shape: RoundedRectangleBorder(),
                        //place name
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        //place types and vicinity
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (types != null)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: typeFormat(types))
                                : Row(),
                            Text(
                              "$vicinity",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        //when the listTile is clicked open place info
                        onTap: () async {
                          Place place = await Place.getPlaceInfo(placeId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlaceInfo(
                                      place: place,
                                      isFav: true,
                                      geo: place.geometry,
                                    )),
                          );
                        }),
                  );
                },
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  //to format the type in the listTile
  List<Text> typeFormat(List list) {
    List<Text> T = [];

    for (int i = 0; i < list.length && i < 2; i++) {
      if (list[i] != null) {
        if (i == 0) {
          T.add(Text(list[i].replaceAll('_', ' ').toString()));
        } else {
          T.add(Text(' \u00b7 ' + list[i].replaceAll('_', ' ').toString()));
        }
      }
    }
    return T;
  }
}
