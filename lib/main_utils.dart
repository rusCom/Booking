class MainUtils {
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    try {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.parse(value);
      return value.toDouble();
    } catch (ex) {
      return defaultValue;
    }
  }

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
