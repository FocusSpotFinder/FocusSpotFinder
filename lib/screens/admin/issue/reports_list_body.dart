import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:focus_spot_finder/models/issue.dart';
import 'package:focus_spot_finder/screens/admin/issue/report_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class reportsListBody extends HookConsumerWidget {
  reportsListBody({Key key}) : super(key: key);

  final issue = Issue();


  @override
  Widget build(BuildContext context, ref) {
    final ValueNotifier<String> search = useState('');

    return VisibilityDetector(
      key: Key('Admin'),

      child: Column(
        children: [
          Row(

              children: [
                SizedBox(
                  width: 20,
                ),
                Text("Filter"),
                SizedBox(
                  width: 15,
                ),

                DropdownButton<String>(

                  hint: (search.value == "")? Text("All", style: GoogleFonts.lato(fontSize: 12,)):Text(search.value, style: GoogleFonts.lato(fontSize: 12,)) ,
                  items: <String>['All', 'Place permanently closed', 'Place not found','Incorrect information' , 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        width: 250,
                        child: Text(value, style: GoogleFonts.lato(fontSize: 12,)),
                      )

                    );
                  }).toList(),
                  onChanged: (value) {
                    if(value == "All"){
                      search.value = "";
                    }else {
                      search.value = value;
                    }
                  },
                ),


              ]
          ),


          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: issue.readReportItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  log(snapshot.error.toString());
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
                      String resovledBy = noteInfo['Resolved by'];

                      if (search != null &&
                          !type
                              .toLowerCase()
                              .contains(search.value.toLowerCase())) {
                        return SizedBox();
                      }

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
                                  resolveTime: resovleTime,
                                  resolvedBy: resovledBy);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => reportInfo(issue: issue)),
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
          )
        ],
      ),
    );
  }
}
