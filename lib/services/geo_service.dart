import 'dart:convert';
import 'dart:io';

import 'package:booking/data/main_application.dart';
import 'package:booking/data/profile.dart';
import 'package:booking/data/route_point.dart';
import 'package:booking/services/map_markers_service.dart';
import 'package:global_configs/global_configs.dart';
import 'package:http/http.dart' as http;

import 'debug_print.dart';

class GeoService {
  final String TAG = (GeoService).toString(); // ignore: non_constant_identifier_names
  static final GeoService _singleton = GeoService._internal();

  factory GeoService() => _singleton;

  GeoService._internal();

  Future<List<String>?> directions(String body, {bool force = false}) async {
    String url = "https://api.ataxi24.ru:7543/geo/directions";
    if (force) {
      url += "?force=1";
    }
    DebugPrint().log(TAG, "directions", url);
    DebugPrint().log(TAG, "directions", body);
    http.Response response = await http.post(Uri.parse(url), body: body, headers: _authHeader);
    if (response.statusCode != 200) return null;
    var result = json.decode(response.body);
    DebugPrint().log(TAG, "directions", result.toString());
    if (result['status'] == 'OK') {
      List<String> res = result['result']['polylines'].cast<String>();
      return res;
    }
    return null;
  }

  Future<List<RoutePoint>?> autocompleteStreetAddress(RoutePoint route) async {
    String url = "https://api.ataxi24.ru:7543/geo/autocomplete/address?route=${route.placeId}";
    DebugPrint().log(TAG, "autocompleteStreetAddress", url);
    http.Response? response = await http.get(Uri.parse(url), headers: _authHeader);
    if (response.statusCode != 200) return null;
    var result = json.decode(response.body);
    DebugPrint().log(TAG, "autocompleteStreetAddress", result.toString());

    if (result['status'] == 'OK') {
      Iterable list = result['result'];
      List<RoutePoint> listRoutePoints = list.map((model) => RoutePoint.fromJson(model)).toList();
      if (listRoutePoints.isEmpty) return null;
      return listRoutePoints;
    }
    return null;
  }

  Future<List<RoutePoint>?> autocompleteAddress(RoutePoint route, String number, String splash) async {
    if (number.isEmpty) return null;
    String url = "https://api.ataxi24.ru:7543/geo/autocomplete/address?route=${route.placeId}&number=$number&splash=$splash";
    DebugPrint().log(TAG, "autocompleteAddress", url);
    http.Response? response = await http.get(Uri.parse(url), headers: _authHeader);
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
        "https://api.ataxi24.ru:7543/geo/autocomplete?keyword=${Uri.encodeFull(input)}&location=${MapMarkersService().pickUpRoutePoint.lt},${MapMarkersService().pickUpRoutePoint.ln}";
    DebugPrint().log(TAG, "autocomplete", url);
    http.Response response = await http.get(Uri.parse(url), headers: _authHeader);
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
    String url = "https://api.ataxi24.ru:7543/geo/detail?place_id=${routePoint.placeId}";
    http.Response response = await http.get(Uri.parse(url), headers: _authHeader);
    if (response.statusCode != 200) return routePoint;
    var result = json.decode(response.body);
    if (result['status'] == 'OK') {
      return RoutePoint.fromJson(result['result']);
    }
    return routePoint;
  }

  Future<bool> geocodeReplaceAddress(String lt, String ln, String place) async {
    String url = "https://api.ataxi24.ru:7543/geo/sys/geocode/replace/address?lt=$lt&ln=$ln&place=$place";
    DebugPrint().log(TAG, "geocodeReplaceAddress", "url = $url");
    http.Response response = await http.get(Uri.parse(url), headers: _authHeader);
    // var result = json.decode(response.body);
    // var response = await RestService().httpGet(url);
    DebugPrint().log(TAG, "geocodeReplaceAddress", "response = $response");
    return true;
  }

  Future<bool> geocodeReplace(String from, String to) async {
    String url = "https://api.ataxi24.ru:7543/geo/sys/geocode/replace?from=$from&to=$to";
    DebugPrint().log(TAG, "geocodeReplace", "url = $url");
    http.Response response = await http.get(Uri.parse(url), headers: _authHeader);
    // var response = await RestService().httpGet(url);
    DebugPrint().log(TAG, "geocodeReplace", "response = $response");
    return true;
  }

  Future<bool> geocodeClear(RoutePoint routePoint) async {
    String url = "https://api.ataxi24.ru:7543/geo/sys/geocode/clear?place_id=${routePoint.placeId}";
    DebugPrint().log(TAG, "geocodeClear", "url = $url");
    // var response = await RestService().httpGet(url);
    http.Response response = await http.get(Uri.parse(url), headers: _authHeader);
    DebugPrint().log(TAG, "geocodeClear", "response = $response");
    return true;
  }

  static Map<String, String> get _authHeader {
    var header = {
      "deviceId": MainApplication().deviceId,
      "token": GlobalConfigs().get("geoToken"),
      "phone": Profile().phone,
      "google_key": MainApplication().preferences.googleKey,
    };

    var bytes = utf8.encode(header.toString());
    var res = base64.encode(bytes);
    return {HttpHeaders.authorizationHeader: "Bearer $res"};
  }
}
