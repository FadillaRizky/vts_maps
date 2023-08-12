import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';

class Constants {
  ///text style
  static TextStyle title1 = TextStyle(
      fontSize: 25, color: Color(0xFF0E286C), fontWeight: FontWeight.bold);
  static TextStyle button1 =
      TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold);

  static double getPointX(BuildContext context) {
    return 40;
  }

  static List<int>? extractKMLDataFromKMZ(List<int> kmzData) {
    final archive = ZipDecoder().decodeBytes(Uint8List.fromList(kmzData));

    for (final file in archive) {
      if (file.name.endsWith('.kml')) {
        return file.content;
      }
    }

    return null;
  }
}
