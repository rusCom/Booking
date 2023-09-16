import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/app_blocs.dart';
import '../services/map_markers_service.dart';
import '../services/rest_service.dart';
import 'order_tariff.dart';
import 'payment_type.dart';

class RoutePoint {
  final String name;
  final String dsc;
  final double lt;
  final double ln;
  final String type;
  final String placeId;
  final String detail;
  final bool needDetail;
  final List<String> notes;
  Key key = ValueKey(const Uuid().v1());
  String _note = "";
  List<OrderTariff> orderTariffs = [];
  List<PaymentType> paymentTypes = [];
  bool canPickUp;

  RoutePoint(
      {this.name = "",
      this.dsc = "",
      this.lt = 0.0,
      this.ln = 0.0,
      this.type = "",
      this.placeId = "",
      this.needDetail = false,
      this.detail = "",
      this.canPickUp = false,
      this.orderTariffs = const [],
      this.paymentTypes = const [],
      this.notes = const [],
      note = ""}) {
    key = ValueKey(const Uuid().v1());
    _note = note;
  }

  factory RoutePoint.fromJson(Map<String, dynamic> jsonData) {
    List<OrderTariff> orderTariffs = [];
    if (jsonData.containsKey('tariffs')) {
      List<String> tariffs = jsonData['tariffs'].cast<String>();
      for (var tariff in tariffs) {
        orderTariffs.add(OrderTariff(type: tariff));
      }
    }
    List<PaymentType> paymentTypes = [];
    if (jsonData.containsKey('payments')) {
      List<String> payments = jsonData['payments'].cast<String>();
      for (var payment in payments) {
        paymentTypes.add(PaymentType(type: payment));
      }
    }

    return RoutePoint(
      name: jsonData['name'] ?? "",
      dsc: jsonData['dsc'] ?? "",
      note: jsonData['note'] ?? "",
      lt: double.tryParse(jsonData['lt'].toString()) ?? 0,
      ln: double.tryParse(jsonData['ln'].toString()) ?? 0,
      needDetail: jsonData['need_detail'] ?? false,
      type: jsonData['type'] ?? "",
      placeId: jsonData['place_id'] ?? "",
      detail: jsonData['detail'] ?? "0",
      notes: jsonData['notes'] != null ? jsonData['notes'].cast<String>() : [],
      canPickUp: jsonData['pick_up'] ?? false,
      orderTariffs: orderTariffs,
      paymentTypes: paymentTypes,
    );
  }

  factory RoutePoint.copy(RoutePoint routePoint) {
    return RoutePoint(
      name: routePoint.name,
      dsc: routePoint.dsc,
      note: routePoint.note,
      lt: routePoint.lt,
      ln: routePoint.ln,
      type: routePoint.type,
      placeId: routePoint.placeId,
      detail: routePoint.detail,
      notes: routePoint.notes,
      canPickUp: routePoint.canPickUp,
      orderTariffs: routePoint.orderTariffs,
      paymentTypes: routePoint.paymentTypes,
    );
  }

  set note(String value) {
    _note = value;
    AppBlocs().newOrderNoteController?.sink.add(_note);
  }

  String get note {
    if (_note == "") {
      return "Подъезд";
    }
    if (_note == null) {
      return "Подъезд";
    }
    return _note;
  }

  bool get isNoteSet {
    if (_note == "") return false;
    if (_note == "Подъезд") return false;
    if (_note == "подъезд") return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
        "payments": paymentTypes,
        "place_id": placeId,
        "name": name,
        "dsc": dsc,
        "lt": lt.toString(),
        "ln": ln.toString(),
        "note": note,
        "notes": notes,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  Future<void> checkPickUp() async {
    return;
    if (canPickUp == null) {
      var response = await RestService().httpGet("/orders/pickup?lt=$lt&ln=$ln");
      if (response['status'] == 'OK') {
        if (response['result']['pick_up'].toString() == "true") {
          orderTariffs = [];
          List<String> tariffs = response['result']['tariffs'].cast<String>();
          for (var tariff in tariffs) {
            orderTariffs.add(OrderTariff(type: tariff));
          }

          paymentTypes = [];
          List<String> payments = response['result']['payments'].cast<String>();
          for (var payment in payments) {
            paymentTypes.add(PaymentType(type: payment));
          }
          canPickUp = true;
          MapMarkersService().pickUpState = PickUpState.enabled;
        } else {
          canPickUp = false;
          MapMarkersService().pickUpState = PickUpState.disabled;
        }
      }
    } else {
      if (canPickUp!) {
        MapMarkersService().pickUpState = PickUpState.enabled;
      } else {
        MapMarkersService().pickUpState = PickUpState.disabled;
      }
    }
  }

  LatLng getLocation() {
    return LatLng(lt, ln);
  }

  Icon getIcon() {
    switch (type) {
      case 'airport':
        return const Icon(Icons.local_airport);
      case 'train_station':
        return const Icon(Icons.train);
      case 'street_address':
        return const Icon(Icons.assistant_photo);
      case 'route':
        return const Icon(Icons.streetview);
      case 'establishment':
        return const Icon(Icons.store);
      case 'locality':
        return const Icon(Icons.location_city);
      case 'city':
        return const Icon(Icons.location_city);
    }
    return const Icon(Icons.location_on);
  }
}
