import 'package:booking/models/preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../services/app_blocs.dart';
import '../services/map_markers_service.dart';
import '../services/rest_service.dart';
import '../ui/utils/core.dart';
import 'agent.dart';
import 'main_application.dart';
import 'order_state.dart';
import 'order_tariff.dart';
import 'order_wishes.dart';
import 'payment_type.dart';
import 'route_point.dart';

class Order {
  final String TAG = (Order).toString(); // ignore: non_constant_identifier_names
  OrderState _orderState = OrderState.newOrder;
  String guid = "";
  List<RoutePoint> routePoints = [];
  String _lastRoutePoints = "";
  String dispatcherPhone = "";
  Agent? agent; // водитель
  bool canDeny = false;
  int distance = 0;

  String price = "";
  OrderWishes orderWishes = OrderWishes();
  List<PaymentType> paymentTypes = [];
  List<OrderTariff> orderTariffs = [];
  String _selectedOrderTariff = "economy";

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
      if (orderState == OrderState.newOrder) {
        calcOrder();
      }
      if (orderState == OrderState.newOrderCalculated) {
        calcOrder();
      }
      MapMarkersService().refresh();
    }
    AppBlocs().orderRoutePointsController?.sink.add(routePoints);
  }

  set orderState(OrderState newOrderState) {
    if (_orderState != newOrderState) {
      DebugPrint().log(TAG, "orderState", "new order state = $newOrderState");

      bool startTimer = false;

      if (_selectedPaymentType == "") {
        _selectedPaymentType = "cash";
      }
      if (_selectedOrderTariff == "") {
        _selectedOrderTariff = "economy";
      }

      switch (newOrderState) {
        case OrderState.newOrder:
          orderWishes.clear();
          startTimer = false;
          moveToCurLocation();
          routePoints.clear();
          if (_orderState.isNewOrderAlarmPlay) {
            MainApplication().playAudioAlarmOrderStateChange();
          }
          break;
        case OrderState.newOrderCalculating:
          startTimer = false;
          AppBlocs().newOrderTariffController?.sink.add(orderTariffs);
          break;
        case OrderState.newOrderCalculated:
          startTimer = false;
          AppBlocs().newOrderTariffController?.sink.add(orderTariffs);
          break;
        case OrderState.searchCar:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.driveToClient:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.driveAtClient:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.paidIdle:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
        case OrderState.clientInCar:
          animateCamera();
          MainApplication().playAudioAlarmOrderStateChange();
          startTimer = true;
          break;
      }

      MainApplication().dataCycle = startTimer;

      _orderState = newOrderState;
      AppBlocs().orderStateController?.sink.add(_orderState);
    } // if (_orderState != value)
  }

  Future<void> calcOrder() async {
    DebugPrint().log(TAG, "calcOrder", toString());
    orderState = OrderState.newOrderCalculating;
    var response = await RestService().httpPost("/orders/calc", toJson());
    if ((response["status"] == "OK") & (orderState == OrderState.newOrderCalculating)) {
      var result = response["result"];
      guid = result['guid'];
      distance = result['distance'];
      paymentTypes.clear();
      orderTariffs.clear();

      Iterable payments = result["payments"];
      paymentTypes = payments.map((model) => PaymentType(type: model)).toList();

      Map<String, dynamic> tariffs = result["tariffs"];
      tariffs.forEach((tariffType, tariffPrice) {
        orderTariffs.add(OrderTariff(type: tariffType, price: tariffPrice));
      });
      orderState = OrderState.newOrderCalculated;

      DebugPrint().log(TAG, "calcOrder", toString());
    }
  }

  OrderState get orderState => _orderState;

  Map<String, dynamic> toJson() => {
        "uid": guid,
        "wishes": orderWishes,
        // "dispatcher_phone": dispatcherPhone,
        "tariff": orderTariff.type,
        "price": orderTariff.price,
        "distance": distance,
        "payment": selectedPaymentType,
        // "state": orderState.toString(),
        // "agent": agent,
        "route": routePoints,
        //"payments": paymentTypes,
      };

  @override
  String toString() {
    return toJson().toString();
  }

  factory Order.fromJson(Map<String, dynamic> jsonData) {
    Order order = Order();
    order.parseData(jsonData, isAnimateCamera: false);
    return order;
  }

  void parseData(Map<String, dynamic> jsonData, {bool isAnimateCamera = true}) {
    DebugPrint().log(TAG, "parseData", jsonData.toString());
    guid = jsonData['guid'];
    dispatcherPhone = jsonData['dispatcher_phone'] ?? "";
    price = jsonData['price'].toString();
    selectedPaymentType = jsonData['payment'] ?? "";
    if (jsonData['wishes'] != null) {
      orderWishes.parseData(jsonData['wishes']);
    } else {
      orderWishes.clear();
    }
    canDeny = MainUtils.parseBool(jsonData['deny']);

    switch (jsonData['state']) {
      case "search_car":
        orderState = OrderState.searchCar;
        break;
      case "drive_to_client":
        orderState = OrderState.driveToClient;
        break;
      case "drive_at_client":
        orderState = OrderState.driveAtClient;
        break;
      case "paid_idle":
        orderState = OrderState.paidIdle;
        break;
      case "client_in_car":
        orderState = OrderState.clientInCar;
        break;

      default:
        orderState = OrderState.newOrder;
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
      try {
        MainApplication().mapController?.animateCamera(CameraUpdate.newLatLngBounds(MapMarkersService().mapBounds(), Preferences().systemMapBounds));
        return true;
      } catch (error) {
        // TODO: handle exception, for example by showing an alert to the user
        return false;
      }
    }
    return false;
  }

  bool get mapBoundsIcon {
    switch (orderState) {
      case OrderState.driveToClient:
        return true;
      case OrderState.driveAtClient:
        return true;
      case OrderState.paidIdle:
        return true;
      case OrderState.clientInCar:
        return true;
      default:
        return false;
    }
  }

  note(String note) async {
    Map<String, dynamic> restResult = await RestService().httpGet("/orders/note?guid=$guid&note=${Uri.encodeFull(note)}");
    MainApplication().parseData(restResult['result']);
    AppBlocs().orderStateController?.sink.add(_orderState);
  }

  deny(String reason) async {
    Map<String, dynamic> restResult = await RestService().httpGet("/orders/deny?guid=$guid&reason=${Uri.encodeFull(reason)}");
    MainApplication().parseData(restResult['result']);
  }

  addOrder() async {
    Map<String, dynamic> restResult = await RestService().httpPost("/orders/add", toJson());
    MainApplication().parseData(restResult['result']);
  }

  void moveToCurLocation() {
    LatLng curLocation = MainApplication().currentLocation;
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

  /// ************************** PaymentTypes ****************************************///

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
      for (var paymentType in paymentTypes) {
        if (paymentType.selected) searchingPaymentType = paymentType;
      }
      if (searchingPaymentType == null) {
        if (_orderState == OrderState.newOrderCalculating || _orderState == OrderState.newOrderCalculated) {
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

  String get selectedOrderTariff => _selectedOrderTariff;

  set selectedOrderTariff(String value) {
    if (_selectedOrderTariff != value) {
      _selectedOrderTariff = value;
      AppBlocs().newOrderTariffController?.sink.add(orderTariffs);
    }
  }

  OrderTariff get orderTariff {
    OrderTariff selectedOrderTariff = OrderTariff(type: "economy");
    for (var orderTariff in orderTariffs) {
      if (orderTariff.selected) {
        selectedOrderTariff = orderTariff;
      }
    }
    return selectedOrderTariff;
  }
}
