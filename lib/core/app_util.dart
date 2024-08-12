import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AppUtil {
  static void showToast(String message) {
    Fluttertoast.showToast(msg: message, gravity: ToastGravity.CENTER);
  }

  static Future<File> compressImage(File file) async {
    // Get the original file path
    String filePath = file.path;

    String compressedFilePath =
        '${filePath.substring(0, filePath.lastIndexOf('.'))}_compressed.jpg';

    XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      compressedFilePath,
      quality: 85, // Adjust quality as needed (0-100)
    );

    // Return the compressed image file
    return File(compressedFile?.path ?? file.path);
  }

  static String convertTimestampInDate(int timestamp) {
    var timestampInSeconds = timestamp ~/ 1000;

    var dateTime =
    DateTime.fromMillisecondsSinceEpoch(timestampInSeconds * 1000);
    var formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(dateTime);
  }

  static String convertTimestampInDateTime(int timestamp) {
    var timestampInSeconds = timestamp ~/ 1000;

    var dateTime =
    DateTime.fromMillisecondsSinceEpoch(timestampInSeconds * 1000);
    var formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(dateTime);
  }
}
