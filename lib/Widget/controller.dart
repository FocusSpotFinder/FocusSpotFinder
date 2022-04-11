import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

class MyController extends GetxController {
  var dropDownText = 'Gender'.obs;
  var userName = ''.obs;


  var f1 = File('').obs;

  final ImagePicker _picker = ImagePicker();

  onImageButtonPressed(
    ImageSource source,
  ) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
      );
      setImageFile(
        f: pickedFile,
      );
    } catch (e) {}
  }

  setImageFile({
    f,
  }) async {
    final filePath = f.path;
    final lastIndex = filePath.lastIndexOf(new RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    final compressedImage = await FlutterImageCompress.compressAndGetFile(filePath, outPath, minWidth: 800, minHeight: 1500, quality: 60);

    // listOfFiles.add(compressedImage);
    f1.value = compressedImage!;
    print('path of file is ===== ${f1.value}');
  }

  void displayBottomSheet(BuildContext context) {
    var height = Get.height;
    var width = Get.width;
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            padding: EdgeInsets.all(width / 30),
            height: MediaQuery.of(context).size.height / 5,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await getCameraPermission();
                            onImageButtonPressed(
                              ImageSource.camera,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.all(width / 100),
                            height: height / 10,
                            width: width / 5,
                            child: Image.asset('assets/camera.png'),
                          ),
                        ),
                        Text(
                          'Camera',
                          style: TextStyle(fontSize: 12, letterSpacing: 0.3, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: width / 20,
                    ),
                    Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await getGalleryPermission();
                            onImageButtonPressed(
                              ImageSource.gallery,
                            );
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.all(width / 100),
                            height: height / 10,
                            width: width / 5,
                            child: Image.asset('assets/gallery.png'),
                          ),
                        ),
                        Text(
                          'Photos',
                          style: TextStyle(fontSize: 12, letterSpacing: 0.3, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
          );
        });
  }

  getCameraPermission() async {
    var camPerm = await Permission.camera.request();
    if (camPerm.isDenied) {
      Fluttertoast.showToast(msg: "Please Allow Camera to take Pictures");
      Permission.camera.request();
    }
    if (camPerm.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Please Go to settings and enable Camera Permission for this Application");
    }
  }

  getGalleryPermission() async {
    var galPerm = await Permission.photos.request();
    if (galPerm.isDenied) {
      Fluttertoast.showToast(msg: "Please Allow Gallery to select Pictures");
      Permission.camera.request();
    }
    if (galPerm.isPermanentlyDenied) {
      Fluttertoast.showToast(msg: "Please Go to settings and enable Gallery Permission for this Application");
    }
  }
}
