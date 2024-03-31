import 'package:global_configs/global_configs.dart';
import 'package:logger/logger.dart';

class DebugPrint {
  final _systemGeocodeReplaceScreen = false;
  final _systemGeocodeAddressReplaceScreen = false;

  final _splashScreen = false;
  final _routePointScreen = false;

  final _restService = false;
  final _geoService = false;
  final _firebaseMessaging = false;

  final _mainApplication = false;
  final _preferences = false;
  final _profile = false;
  final _order = false;
  final _paymentType = false;

  log(className, classMethod, message) {
    if (GlobalConfigs().get("isTest") == null)return;
    if (!GlobalConfigs().get("isTest")) return;
    bool isPrint = false;

    if (className == "SplashScreen" && _splashScreen) isPrint = true;
    if (className == "RestService" && _restService) isPrint = true;
    if (className == "Preferences" && _preferences) isPrint = true;
    if (className == "Profile" && _profile) isPrint = true;

    if (className == "GeoService" && _geoService) isPrint = true;
    if (className == "MainApplication" && _mainApplication) isPrint = true;
    if (className == "FirebaseMessaging" && _firebaseMessaging) isPrint = true;

    if (className == "Order" && _order) isPrint = true;
    if (className == "PaymentType" && _paymentType) isPrint = true;
    if (className == "RoutePointScreen" && _routePointScreen) isPrint = true;

    if (className == "SystemGeocodeReplaceScreen" && _systemGeocodeReplaceScreen) isPrint = true;
    if (className == "SystemGeocodeAddressReplaceScreen" && _systemGeocodeAddressReplaceScreen) isPrint = true;

    if (className == "sys") isPrint = true;

    if (isPrint) {
      Logger().v("${"${"########## " + className}." + classMethod}: $message");
    }
  }

  flog(message) {
    if (GlobalConfigs().get("isTest")) {
      Logger().v("########## $message");
    }
  }
}
