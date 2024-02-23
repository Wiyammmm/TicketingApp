import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppColors {
  static const Color secondaryColor = Color.fromARGB(255, 255, 225, 225);
  static Color get primaryColor => getDynamicColor();
  static Color getDynamicColor() {
    final _myBox = Hive.box('myBox');
    final coopData = _myBox.get('coopData');
    if (coopData != null && coopData.isNotEmpty) {
      if (coopData['_id'] == "655321a339c1307c069616e9") {
        return Color(0xffc00000);
        // return Color(0xFF00558d);
      } else {
        return Color(0xFF00558d);
        // return Color(0xffc00000);
      }
    } else {
      return Color(0xFF00558d);
      // return Color(0xffc00000);
    }
  }
  // Add more colors as needed...
}
