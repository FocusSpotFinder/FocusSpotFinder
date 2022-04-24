import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FavoriteListModel {
  Stream<QuerySnapshot> favListItems;

  FavoriteListModel({this.favListItems});

  //read the favorite list docs that is in the user collection
  Stream<QuerySnapshot> readItems() {
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference itemCollectionFav = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection('Favorites')
        .doc()
        .parent;
    favListItems = itemCollectionFav.snapshots();
    return favListItems;
  }

  //add place to fav list collection
  Future<void> addItem(
      String placeId, String name, String vicinity, List<dynamic> types) async {
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection("Favorites")
        .doc(placeId)
        .set({
      'placeId': placeId,
      'name': name,
      'vicinity': vicinity,
      'types': types,
    });

    Fluttertoast.showToast(
      msg: "Place Added to Favorite List Successfully",
      toastLength: Toast.LENGTH_LONG,
    );
  }

  //remove place from fav list collection
  Future<void> deleteItem(String placeId) async {
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .collection("Favorites")
        .doc(placeId)
        .delete()
        .whenComplete(() => Fluttertoast.showToast(
              msg: "Place Removed from Favorite List Successfully",
              toastLength: Toast.LENGTH_LONG,
            ))
        .catchError((e) => print(e));
  }
}
