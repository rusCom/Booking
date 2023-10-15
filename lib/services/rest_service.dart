import 'dart:convert';
import 'dart:io';

import 'package:global_configs/global_configs.dart';

import '../models/main_application.dart';
import '../models/preferences.dart';
import '../ui/utils/core.dart';

import 'package:http/http.dart' as http;

class RestService {
  final String TAG = (RestService).toString(); // ignore: non_constant_identifier_names
  static final RestService _singleton = RestService._internal();

  factory RestService() => _singleton;

  RestService._internal();

  int _curRestIndex = 1;

  Future<Map<String, dynamic>> httpGet(path) async {
    late Map<String, dynamic> result;

    http.Response? response;
    String url = GlobalConfigs().get("restHost")[_curRestIndex] + path;
    DebugPrint().log(TAG, "httpGet", "path = $url");
    response = await _httpGetH(url);
    if (response == null) {
      for (var host in GlobalConfigs().get("restHost")) {
        if ((response == null) & (GlobalConfigs().get("restHost").indexOf(host) != _curRestIndex)) {
          url = host + path;
          response = await _httpGetH(url);
          if (response != null) {
            _curRestIndex = GlobalConfigs().get("restHost").indexOf(host);
          }
        }
      } // for (var host in AppSettings.restHost){
    } // if (response == null){

    if (response != null) {
      if (response.statusCode == 200) {
        result = json.decode(response.body);
      }
      if (response.statusCode == 401) {
        result = json.decode(response.body);
      }
    }
    DebugPrint().log(TAG, "httpGet", "result = $result");
    return result;
  }

  Future<http.Response?> _httpGetH(url) async {
    http.Response? response;
    try {
      response = await http.get(
        Uri.parse(url),
        headers: {HttpHeaders.authorizationHeader: "Bearer ${_authHeader()}"},
      ).timeout(
        Duration(seconds: Preferences().systemHttpTimeOut),
        onTimeout: () {
          DebugPrint().log(TAG, "_httpGetH", "$url timeout");
          return Future.value(null);
        },
      );
    } catch (e) {
      DebugPrint().log(TAG, "_httpGetH", "catch error = $e");
    }

    return response;
  }

  String _authHeader() {
    var header = {
      "deviceId": MainApplication().deviceId,
      "dispatching": GlobalConfigs().get("dispatchingToken"),
      "lt": MainApplication().currentPosition?.latitude,
      "ln": MainApplication().currentPosition?.longitude,
      "location": MainApplication().currentPosition?.toJson(),
      "platform": "android",
      "token": MainApplication().clientToken,
      "test": GlobalConfigs().get("isTest"),
    };

    DebugPrint().log(TAG, "_authHeader", header);

    var bytes = utf8.encode(header.toString());
    var res = base64.encode(bytes);
    DebugPrint().log(TAG, "_authHeader", res);
    return res;
  }
}
