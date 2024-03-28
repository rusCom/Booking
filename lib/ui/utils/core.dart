import 'package:flutter/material.dart';


class MainUtils {
  static bool parseBool(var value) {
    if (value == null) return false;
    if (value.toString().toLowerCase() == "true") return true;
    if (value.toString() == "1") return true;
    return false;
  }

  static int parseInt(var value, {var def = 0}) {
    if (value == null) return def;
    return int.parse(value.toString());
  }

  static String jsonGetString(Map<String, dynamic> jsonData, String fieldName, {String defaultValue = ""}) {
    if (jsonData.isEmpty) return defaultValue;
    if (!jsonData.containsKey(fieldName)) return defaultValue;
    return jsonData[fieldName];
  }
}

class Const {
  static List<Color> kitGradients = [
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static const List<Color> signUpGradients = [
    Color(0xFFFF9945),
    Color(0xFFFc6076),
  ];

  static const modalBottomSheetsBorderRadius = Radius.circular(10.0);
  static const modalBottomSheetsLeadingSize = 32.0;
}


