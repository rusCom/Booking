import 'dart:convert';

import 'package:booking/services/map_markers_service.dart';
import 'package:booking/services/rest_service2.dart';
import 'package:global_configs/global_configs.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/main_application.dart';
import '../models/profile.dart';
import '../models/route_point.dart';
import '../ui/utils/core.dart';

class GeoService {
  final String TAG = (GeoService).toString(); // ignore: non_constant_identifier_names
  static final GeoService _singleton = GeoService._internal();

  factory GeoService() => _singleton;

  GeoService._internal();

  RoutePoint? _lastGeoCodeRoutePoint;

  LatLng _lastGeoCodeLocation = const LatLng(0, 0);

  Future<List<String>?> directions(String body) async {
    String url = "http://api.ataxi24.ru:7580/geo/directions?"
        "&google_key=${MainApplication().preferences.googleKey}&token=${GlobalConfigs().get("geoToken")}";
    DebugPrint().log(TAG, "directions", url);
    DebugPrint().log(TAG, "directions", body);
    http.Response response = await http.post(Uri.parse(url), body: body);
    if (response.statusCode != 200) return null;
    var result = json.decode(response.body);
    DebugPrint().log(TAG, "directions", result.toString());
    if (result['status'] == 'OK') {
      List<String> res = result['result']['polylines'].cast<String>();
      return res;
    }
    return null;
  }

  Future<List<RoutePoint>?> autocompleteAddress(RoutePoint route, String number, String splash) async {
    if (number.isEmpty) return null;
    String url = "http://api.ataxi24.ru:7580/geo/autocomplete/address?route=${route.placeId}&number=$number&splash=$splash"
        "&google_key=${MainApplication().preferences.googleKey}&token=${GlobalConfigs().get("geoToken")}";
    DebugPrint().log(TAG, "autocompleteAddress", url);
    http.Response? response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;
    var result = json.decode(response.body);
    DebugPrint().log(TAG, "autocompleteHouse", result.toString());

    if (result['status'] == 'OK') {
      Iterable list = result['result'];
      List<RoutePoint> listRoutePoints = list.map((model) => RoutePoint.fromJson(model)).toList();
      if (listRoutePoints.isEmpty) return null;
      return listRoutePoints;
    }
    return null;
  }

  Future<List<RoutePoint>?> autocomplete(String input) async {
    if (input.isEmpty) return null;
    if (input == "") return null;
    String url =
        "http://api.ataxi24.ru:7580/geo/autocomplete?keyword=${Uri.encodeFull(input)}&location=${MapMarkersService().pickUpRoutePoint.lt},${MapMarkersService().pickUpRoutePoint.ln}"
        "&google_key=${MainApplication().preferences.googleKey}&token=${GlobalConfigs().get("geoToken")}";
    DebugPrint().log(TAG, "autocomplete", url);
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;
    var result = json.decode(response.body);
    DebugPrint().log(TAG, "autocomplete", result.toString());

    if (result['status'] == 'OK') {
      Iterable list = result['result'];
      List<RoutePoint> listRoutePoints = list.map((model) => RoutePoint.fromJson(model)).toList();
      return listRoutePoints;
    }
    return null;
  }

  Future<RoutePoint> detail(RoutePoint routePoint) async {
    String url = "http://api.ataxi24.ru:7580/geo/detail?place_id=${routePoint.placeId}"
        "&google_key=${MainApplication().preferences.googleKey}&token=${GlobalConfigs().get("geoToken")}";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return routePoint;
    var result = json.decode(response.body);
    if (result['status'] == 'OK') {
      return RoutePoint.fromJson(result['result']);
    }
    return routePoint;
  }

  Future<RoutePoint?> geocode(LatLng location) async {
    if (location == _lastGeoCodeLocation) return _lastGeoCodeRoutePoint;
    String url = "http://api.ataxi24.ru:7580/geo/geocode?lt=${location.latitude}&ln=${location.longitude}"
        "&google_key=${MainApplication().preferences.googleKey}&token=${GlobalConfigs().get("geoToken")}";
    /*
    DebugPrint().log(TAG, "geocode", "url = $url");
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;
    var result = json.decode(response.body);
    */
    var result = await RestService2.httpGET(url);

    DebugPrint().log(TAG, "geocode", "result = $result");
    if (result['status'] == 'OK') {
      _lastGeoCodeLocation = location;
      RoutePoint routePoint = RoutePoint.fromJson(result['result']);
      _lastGeoCodeRoutePoint = routePoint;
      return routePoint;
    }
    return null;
  }

  Future<bool> geocodeReplaceAddress(String lt, String ln, String place) async {
    String url = "http://geo.toptaxi.org/geocode/replace/address?lt=$lt&ln=$ln&place=$place&phone=${Profile().phone}";
    DebugPrint().log(TAG, "geocodeReplaceAddress", "url = $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    DebugPrint().log(TAG, "geocodeReplaceAddress", "response = $result");
    return true;
  }

  Future<bool> geocodeReplace(String from, String to) async {
    String url = "http://geo.toptaxi.org/geocode/replace?from=$from&to=$to&phone=${Profile().phone}";
    DebugPrint().log(TAG, "geocodeReplace", "url = $url");
    http.Response response = await http.get(Uri.parse(url));
    DebugPrint().log(TAG, "geocodeReplace", "response = $response");
    return true;
  }

  Future<bool> geocodeClear(RoutePoint routePoint) async {
    String url = "http://geo.toptaxi.org/geocode/clear?place_id=${routePoint.placeId}&phone=${Profile().phone}";
    DebugPrint().log(TAG, "geocodeClear", "url = $url");
    http.Response response = await http.get(Uri.parse(url));
    DebugPrint().log(TAG, "geocodeClear", "response = $response");
    return true;
  }
}
