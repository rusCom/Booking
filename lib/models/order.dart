import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:booking/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../services/app_blocs.dart';
import '../services/map_markers_service.dart';
import '../services/rest_service.dart';
import '../ui/utils/core.dart';
import 'agent.dart';
import 'main_application.dart';
import 'order_tariff.dart';
import 'order_wishes.dart';
import 'payment_type.dart';
import 'route_point.dart';

enum OrderState {
  new_order,
  new_order_calculating,
  new_order_calculated,
  search_car,
  drive_to_client,
  drive_at_client,
  paid_idle,
  client_in_car,
}

class Order {
  final String TAG = (Order).toString(); // ignore: non_constant_identifier_names
  OrderState _orderState = OrderState.new_order;
  String _uid = "";
  List<RoutePoint> routePoints = [];
  String _lastRoutePoints = "";
  String dispatcherPhone = "";
  Agent? agent; // водитель
  bool canDeny = false;

  String cost = "";
  OrderWishes orderWishes = OrderWishes();

  Order();

  String getLastRouteName() {
    if (routePoints.length == 1) {
      return "";
    } else if (routePoints.length == 2) {
      return routePoints.last.name;
    } else if (routePoints.length == 3) {
      return routePoints.last.name;
    } else {
      return "Еще ${routePoints.length - 1} адреса";
    }
  }

  String getLastRouteDsc() {
    if (routePoints.length == 2) return routePoints.last.dsc;
    if (routePoints.length == 3) return "через ${routePoints[1].name}";
    return "";
  }

  void deleteRoutePoint(Key item) {
    routePoints.removeAt(_indexRoutePointOfKey(item));
    AppBlocs().orderRoutePointsController?.sink.add(routePoints);
    MapMarkersService().refresh();
  }

  bool reorderRoutePoints(Key item, Key newPosition) {
    int draggingIndex = _indexRoutePointOfKey(item);
    int newPositionIndex = _indexRoutePointOfKey(newPosition);
    final draggedItem = routePoints[draggingIndex];
    routePoints.removeAt(draggingIndex);
    routePoints.insert(newPositionIndex, draggedItem);
    routePoints.first.checkPickUp();
    AppBlocs().orderRoutePointsController?.sink.add(routePoints);
    MapMarkersService().refresh();
    return true;
  }

  int _indexRoutePointOfKey(Key key) {
    return routePoints.indexWhere((RoutePoint d) => d.key == key);
  }

  void addRoutePoint(RoutePoint routePoint, {bool isLast = false}) {
    if (isLast) {
      routePoints.last = routePoint;
    } else {
      routePoints.add(routePoint);
    }

    if (routePoints.length > 1) {
      if (orderState == OrderState.new_order) {
        calcOrder();
      }
      if (orderState == OrderState.new_order_calculated) {
        calcOrder();
      }
      MapMarkersService().refresh();
    }
    AppBlocs().orderRoutePointsController?.sink.add(routePoints);
  }

  set orderState(OrderState value) {
    if (_orderState != value) {
      DebugPrint().log(TAG, "orderState", "new order state = $value");

      bool startTimer = false;
      _orderState = value;
      if (_selectedPaymentType == "") {
        _selectedPaymentType = "cash";
      }
      if (_selectedOrderTariff == "") {
        _selectedOrderTariff = "econom";
      }

      switch (_orderState) {
        case OrderState.new_order:
          orderWishes.clear();
          startTimer = false;
          moveToCurLocation();
          routePoints.clear();
          break;
        case OrderState.new_order_calculating:
          startTimer = false;
          AppBlocs().newOrderTariffController?.sink.add(orderTariffs);
          break;
        case OrderState.new_order_calculated:
          startTimer = false;
          AppBlocs().newOrderTariffController?.sink.add(orderTariffs);
          break;
        case OrderState.search_car:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.drive_to_client:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.drive_at_client:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.paid_idle:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.client_in_car:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
      }

      MainApplication().dataCycle = startTimer;

      AppBlocs().orderStateController?.sink.add(_orderState!);
    } // if (_orderState != value)
  }

  Future<void> calcOrder() async {
    DebugPrint().log(TAG, "calcOrder", toString());
    Logger().v(toJson().toString());
    orderState = OrderState.new_order_calculating;

    var response = await RestService().httpPost("/orders/calc", toJson());
    if (response["status"] == "OK") {
      var result = response["result"];
      _uid = result['uid'];

      Iterable payments = result["payments"];
      paymentTypes = payments.map((model) => PaymentType.fromJson(model)).toList();
      orderState = OrderState.new_order_calculated;

      DebugPrint().log(TAG, "calcOrder", toString());
    }
  }

  OrderState get orderState => _orderState;

  Map<String, dynamic> toJson() => {
        "uid": _uid,
        "wishes": orderWishes,
        "dispatcher_phone": dispatcherPhone,
        "tariff": selectedOrderTariff,
        "payment": selectedPaymentType,
        "state": orderState.toString(),
        "agent": agent,
        "route": routePoints,
        "payments": paymentTypes,
        "routeNote": routeNote,
      };

  String get routeNote {
    if (routePoints == null) return "";
    if (routePoints.isEmpty) return "";
    if (!routePoints.first.isNoteSet) return "";
    return routePoints.first.note;
  }

  @override
  String toString() {
    return toJson().toString();
  }

  factory Order.fromJson(Map<String, dynamic> jsonData) {
    Order order = Order();
    order.parseData(jsonData, isAnimateCamera: false);
    // DebugPrint().flog(order);
    return order;
  }

  void parseData(Map<String, dynamic> jsonData, {bool isAnimateCamera = true}) {
    DebugPrint().log(TAG, "parseData", jsonData.toString());
    _uid = jsonData['uid'];
    dispatcherPhone = jsonData['dispatcher_phone'];
    cost = jsonData['cost'] ?? "";
    selectedPaymentType = jsonData['payment'] ?? "";
    if (jsonData['wishes'] != null) {
      orderWishes.parseData(jsonData['wishes']);
    } else {
      orderWishes.clear();
    }
    canDeny = MainUtils.parseBool(jsonData['deny']);

    // DebugPrint().flog(orderWishes.count);

    switch (jsonData['state']) {
      case "search_car":
        orderState = OrderState.search_car;
        break;
      case "drive_to_client":
        orderState = OrderState.drive_to_client;
        break;
      case "drive_at_client":
        orderState = OrderState.drive_at_client;
        break;
      case "paid_idle":
        orderState = OrderState.paid_idle;
        break;
      case "client_in_car":
        orderState = OrderState.client_in_car;
        break;

      default:
        orderState = OrderState.new_order;
        break;
    }
    if (jsonData.containsKey("agent")) {
      agent = Agent.fromJson(jsonData['agent']);
      MapMarkersService().agentMarkerRefresh();
    } else {
      agent = null;
      MapMarkersService().clearAgentMarker();
    }

    if (jsonData.containsKey("route")) {
      if (_lastRoutePoints != jsonData['route'].toString()) {
        // если есть изменения по точкам маршрута
        Iterable list = jsonData['route'];
        routePoints = list.map((model) => RoutePoint.fromJson(model)).toList();
        if (isAnimateCamera) {
          MapMarkersService().refresh();
          if (animateCamera()) {
            _lastRoutePoints = jsonData['route'].toString();
          }
        }
      } // if (_lastRoutePoints != jsonData['route'].toString()){
    }
    DebugPrint().log(TAG, "parseData", toString());
  }

  bool animateCamera() {
    if (MainApplication().mapController != null) {
      MainApplication().mapController?.animateCamera(CameraUpdate.newLatLngBounds(MapMarkersService().mapBounds(), Preferences().systemMapBounds));
      return true;
    }
    return false;
  }

  bool get mapBoundsIcon {
    switch (orderState) {
      case OrderState.drive_to_client:
        return true;
      case OrderState.drive_at_client:
        return true;
      case OrderState.paid_idle:
        return true;
      case OrderState.client_in_car:
        return true;
      default:
        return false;
    }
  }

  note(String note) async {
    Map<String, dynamic> restResult = await RestService().httpGet("/orders/note?uid=$_uid&note=${Uri.encodeFull(note)}");
    MainApplication().parseData(restResult['result']);
    AppBlocs().orderStateController?.sink.add(_orderState);
  }

  deny(String reason) async {
    Map<String, dynamic> restResult = await RestService().httpGet("/orders/deny?uid=$_uid&reason=${Uri.encodeFull(reason)}");
    MainApplication().parseData(restResult['result']);
  }

  add() async {
    Map<String, dynamic> restResult = await RestService().httpPost("/orders/add", toJson());
    MainApplication().parseData(restResult['result']);
  }

  void moveToCurLocation() {
    LatLng curLocation = MainApplication().currentLocation;
    if (curLocation != null) {
      if (MainApplication().mapController != null) {
        MainApplication().mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: curLocation,
                  zoom: 17.0,
                ),
              ),
            );
      }
    }
  }

  /// ************************** PaymentTypes ****************************************///
  List<PaymentType> paymentTypes = [];
  String _selectedPaymentType = "cash";

  String get selectedPaymentType => _selectedPaymentType;

  set selectedPaymentType(String value) {
    if (_selectedPaymentType != value) {
      _selectedPaymentType = value;
      AppBlocs().newOrderPaymentController?.sink.add(_selectedPaymentType);
    }
  }

  PaymentType? paymentType({type = ""}) {
    PaymentType? searchingPaymentType;

    if (type == "") {
      if (paymentTypes.isEmpty) {
        if (searchingPaymentType == null) {
          for (var paymentType in routePoints[0].paymentTypes) {
            if (paymentType.selected) searchingPaymentType = paymentType;
          }
        }
      }
      for (var paymentType in paymentTypes) {
        if (paymentType.selected) searchingPaymentType = paymentType;
      }
      if (searchingPaymentType == null) {
        if (_orderState == OrderState.new_order_calculating || _orderState == OrderState.new_order_calculated) {
          _selectedPaymentType = "cash";
        }

        searchingPaymentType = PaymentType(type: _selectedPaymentType);
      }
    } // if (type == ""){
    else {
      for (var paymentType in paymentTypes) {
        if (paymentType.type == type) searchingPaymentType = paymentType;
      }
    } // if (type == ""){ ... else
    return searchingPaymentType;
  }

  /// ************************** OrderTariffs ****************************************///
  String _selectedOrderTariff = "econom";

  String get selectedOrderTariff => _selectedOrderTariff;

  set selectedOrderTariff(String value) {
    if (_selectedOrderTariff != value) {
      _selectedOrderTariff = value;
      AppBlocs().newOrderTariffController?.sink.add(orderTariffs);
    }
  }

  List<OrderTariff> get orderTariffs {
    if (paymentTypes.isEmpty) {
      return routePoints.first.orderTariffs;
    }
    PaymentType? result;
    for (var paymentType in paymentTypes) {
      if (paymentType.selected) result = paymentType;
    }
    if (result == null) return [];
    return result.orderTariffs;
  }

  OrderTariff get orderTariff {
    OrderTariff selectedOrderTariff = OrderTariff(type: "econom");
    for (var orderTariff in orderTariffs) {
      if (orderTariff.selected) {
        selectedOrderTariff = orderTariff;
      }
    }
    return selectedOrderTariff;
  }
}
