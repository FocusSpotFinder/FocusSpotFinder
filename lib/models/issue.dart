import 'package:cloud_firestore/cloud_firestore.dart';

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

  Stream<QuerySnapshot> readItems() {
    Query reportsCollection = FirebaseFirestore.instance
        .collection('Reports')
        .orderBy('Status', descending: true);


    issues = reportsCollection.snapshots();
    return issues;
  }

}
