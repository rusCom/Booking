import 'package:flutter/material.dart';

import '../ui/utils/core.dart';
import 'order_tariff.dart';
import 'payment_type.dart';

class Preferences {
  final String TAG = (Preferences).toString(); // ignore: non_constant_identifier_names
  static final Preferences _singleton = Preferences._internal();

  factory Preferences() => _singleton;

  Preferences._internal();

  String administrationPhone = "";
  String googleKey = "";
  bool mapDirections = false;
  List<PaymentType> paymentTypes = [];
  List<OrderTariff> orderTariffs = [];
  bool geocodeMove = false;

  bool systemMapAdmin = false;
  double systemMapBounds = 35.0;
  int systemHttpTimeOut = 10;
  int systemTimerTask = 5;
  int wishesBabySeatsCount = 1;
  Color mainColor = Colors.amber;
  int mainColorCode = 0xFFFFC107;

  void parseData(Map<String, dynamic> jsonData) {
    DebugPrint().log(TAG, "parseData", jsonData);

    administrationPhone = jsonData['administration_phone'] ?? "";
    googleKey = jsonData['google_key'] ?? "";

    if (jsonData['system'] != null) {
      systemMapAdmin = MainUtils.parseBool(jsonData['system']['map_admin']);
      mapDirections = MainUtils.parseBool(jsonData['system']['map_directions']);
      systemHttpTimeOut = MainUtils.parseInt(jsonData['system']['http_timeout'], def: 20);
      systemTimerTask = MainUtils.parseInt(jsonData['system']['timer_task'], def: 5);
      mainColorCode = MainUtils.parseInt(jsonData['system']['main_color'], def: 0xFFFFC107);
      mainColor = Color(mainColorCode);
    }

    if (jsonData.containsKey('payments')) {
      paymentTypes = [];
      List<String> payments = jsonData['payments'].cast<String>();
      for (var payment in payments) {
        paymentTypes.add(PaymentType(type: payment));
      }
    }
    if (jsonData.containsKey('tariffs')) {
      orderTariffs = [];
      List<String> tariffs = jsonData['tariffs'].cast<String>();
      for (var tariff in tariffs) {
        orderTariffs.add(OrderTariff(type: tariff));
      }
    }
  }

  PaymentType paymentType(String type) {
    PaymentType result = PaymentType(type: "cash");
    for (var paymentType in paymentTypes) {
      if (paymentType.type == type) {
        result = paymentType;
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        "administrationPhone": administrationPhone,
        "paymentTypes": paymentTypes,
        "orderTariffs": orderTariffs,
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
