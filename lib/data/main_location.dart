import 'dart:math';

import 'package:booking/main_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart';

class MainLocation {
  late double latitude;
  late double longitude;
  late double bearing;
  late DateTime regDate;

  MainLocation({required this.latitude, required this.longitude, required this.regDate, required this.bearing});

  MainLocation.nullable() {
    latitude = 0.0;
    longitude = 0.0;
    bearing = 0.0;
    regDate = DateTime.now();
  }

  factory MainLocation.fromJson(Map<String, dynamic> jsonData) {
    return MainLocation(
      latitude: MainUtils.parseDouble(jsonData['lt']),
      longitude: MainUtils.parseDouble(jsonData['ln']),
      bearing: MainUtils.parseDouble(jsonData['bearing']),
      regDate: jsonData["reg_date"] != null ? DateTime.parse(jsonData["reg_date"]) : DateTime.now(),
    );
  }

  bool isSame(MainLocation otherLocation) {
    return latitude == otherLocation.latitude && longitude == otherLocation.longitude;
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  double calcBearing(MainLocation lastLocation) {
    double lat = (lastLocation.latitude - latitude).abs();
    double lng = (lastLocation.longitude - longitude).abs();

    if (lastLocation.latitude < latitude && lastLocation.longitude < longitude) {
      return degrees(atan(lng / lat));
    } else if (lastLocation.latitude >= latitude && lastLocation.longitude < longitude) {
      return (90 - degrees(atan(lng / lat))) + 90;
    } else if (lastLocation.latitude >= latitude && lastLocation.longitude >= longitude) {
      return degrees(atan(lng / lat)) + 180;
    } else if (lastLocation.latitude < latitude && lastLocation.longitude >= longitude) {
      return (90 - degrees(atan(lng / lat))) + 270;
    }
    return -1;
  }
}
