import '../services/rest_service.dart';
import '../services/rest_service2.dart';
import '../ui/utils/core.dart';
import 'main_application.dart';

class Profile {
  final String TAG = (Profile).toString(); // ignore: non_constant_identifier_names
  static final Profile _singleton = Profile._internal();

  factory Profile() => _singleton;

  Profile._internal();

  String phone = "", code = "";

  void parseData(Map<String, dynamic> jsonData) {
    phone = jsonData['phone'] ?? "";
  }

  String get maskedPhone {
    String res = "+7 (";
    res += "${phone.substring(1, 4)}) ";
    res += "${phone.substring(4, 7)} ";
    res += "${phone.substring(7, 9)}-${phone.substring(9, 11)}";
    return res;
  }

  Future<String> auth() async {
    String url = "/profile/auth";
    if (MainApplication().pushToken != "") {
      url += "?push_token=${MainApplication().pushToken}";
    }

    Map<String, dynamic> restResult = await RestService2().httpGet(url);
    DebugPrint().log(TAG, "auth", restResult.toString());
    if (restResult['status'] == 'OK') {
      MainApplication().parseData(restResult['result']);
      if (restResult['result'].containsKey("profile")) {
        Map<String, dynamic> restResultData = await RestService2().httpGet("/data");
        MainApplication().parseData(restResultData['result']);
      }
    }
    if (restResult['status'] == 'UNAUTHORIZED') {
      if (restResult.containsKey('error')) {
        MainApplication().parseData(restResult['error']);
      }
    }
    return restResult['status'];
  }

  Future<String> login() async {
    Map<String, dynamic> restResult = await RestService().httpGet("/profile/login?phone=$phone");
    if (restResult['status'] == 'OK') {
      return "OK";
    }
    return restResult['error'];
  }

  Future<String> registration() async {
    Map<String, dynamic> restResult = await RestService().httpGet("/profile/registration?phone=$phone&code=$code");
    if (restResult['status'] == 'OK') {
      DebugPrint().log(TAG, "registration", restResult['result']);
      MainApplication().clientToken = restResult['result'];
      return "OK";
    }
    return restResult['error'];
  }
}
