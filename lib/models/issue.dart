import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Issue {
  String placeId;
  String userId;
  String reportId;
  String type;
  String status;
  String message;
  String reportTime;
  String resolveTime;
  String resolvedBy;

  Stream<QuerySnapshot> issues;

  Issue({this.placeId, this.userId, this.reportId, this.type, this.status, this.message,
    this.reportTime, this.resolveTime, this.resolvedBy, this.issues});

  Stream<QuerySnapshot> readReportItems() {
    deleteOldReports();

    Query reportsCollection = FirebaseFirestore.instance
        .collection('Reports')
        .orderBy('Status', descending: true)
        .orderBy('Report time', descending: true);

    issues = reportsCollection.snapshots();
    return issues;
  }

  Stream<QuerySnapshot> readNotificationsItems() {
    deleteOldReports();

    Query reportsCollection = FirebaseFirestore.instance
        .collection('Notifications')
        .orderBy('Status', descending: true)
        .orderBy('Report time', descending: true);

    issues = reportsCollection.snapshots();
    return issues;
  }

  deleteOldReports() async {

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Reports').get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();


    for (int x = 0; x < allData.length; x++) {
      var noteInfo = querySnapshot.docs[x].data() as Map<String, dynamic>;
      DateTime currentTime = DateTime.now();
      DateFormat dateFormat = new DateFormat('yyyy-MM-dd HH:mm:ss');
      if(noteInfo["Report time"] == null){
        continue;
      }else{
        DateTime resolveTime = dateFormat.parse(noteInfo["Report time"]);
        DateTime invalidTime = DateTime(
          resolveTime.year + 1,
          resolveTime.month,
          resolveTime.day,
        );

        if( invalidTime.isBefore(currentTime)){
          FirebaseFirestore.instance.collection('Reports').doc(querySnapshot.docs[x].id).delete();
          log("old doc");
        }
      }

    }
  }


}
