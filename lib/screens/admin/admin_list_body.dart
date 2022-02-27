import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/screens/admin/issue_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

class adminListBody extends HookConsumerWidget {
  adminListBody({Key key}) : super(key: key);

  final issues = Issue();


  @override
  Widget build(BuildContext context, ref) {
    return VisibilityDetector(
      key: Key('Admin'),

      child: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: issues.readItems(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              } else if (snapshot.hasData || snapshot.data != null) {
                return ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(height: 7.0),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var noteInfo = snapshot.data.docs[index].data() as Map<String, dynamic>;
                    String placeId = noteInfo['PlaceId'];
                    String userId = noteInfo['UserId'];
                    String reportId = snapshot.data.docs[index].id;
                    String type = noteInfo['Type'];
                    String status = noteInfo['Status'];
                    String message = noteInfo['Message'];
                    String reportTime = noteInfo['Report time'];
                    String resovleTime = noteInfo['Resolve time'];

                    return Ink(
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                      ),
                      child: ListTile(
                          isThreeLine: false,
                          shape: RoundedRectangleBorder(),
                          title: Text(
                            type,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: (status == "Unresolved" || status == "Waiting")?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "$status",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                color: Colors.red,
                              ),
                              ),
                            ],
                          ):
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "$status",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {

                            Issue issue = new Issue(
                                placeId: placeId,
                                userId: userId,
                                reportId: reportId,
                                type: type,
                                status: status,
                                message: message,
                                reportTime: reportTime,
                                resolveTime: resovleTime );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => issueInfo(issue: issue)),
                            );
                          }
                          ),
                    );
                  },
                );
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
    );
  }
}
