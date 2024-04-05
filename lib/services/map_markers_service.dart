import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:booking/constants/style.dart';
import 'package:booking/data/main_application.dart';
import 'package:booking/data/main_location.dart';
import 'package:booking/data/order_state.dart';
import 'package:booking/data/route_point.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'app_blocs.dart';
import 'geo_service.dart';

enum PickUpState { searching, enabled, disabled, init }

class MapMarkersService {
  static final MapMarkersService _instance = MapMarkersService._internal();
  String lastRoutePointPolylineData = "";

  factory MapMarkersService() {
    return _instance;
  }

  MapMarkersService._internal();

  final Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  final Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};

  final MarkerId _mapPickUpMarkerID = const MarkerId('_mapPickUpMarkerID');
  final MarkerId _mapDestinationMarkerID = const MarkerId('_mapDestinationMarkerID');
  final MarkerId _mapAgentMarkerID = const MarkerId('_mapAgentMarkerID');

  final _mapMarkerSC = StreamController<Set<Marker>>();

  StreamSink<Set<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  Stream<Set<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  LatLng _pickUpLocation = MainApplication().currentLocation;
  RoutePoint _pickUpRoutePoint = RoutePoint();
  PickUpState _pickUpState = PickUpState.init;

  final List<MainLocation> _agentLocations = [];
  MainLocation _lastAgentLocation = MainLocation.nullable();
  bool _agentLocationAnimate = false;
  late TickerProvider agentLocationTickerProvider;

  late final Marker _mapPickUpMarker, _mapDestinationMarker, _mapAgentMarker;

  late final BitmapDescriptor _mapAddressIcon;

  init(BuildContext context) async {
    _mapAddressIcon = BitmapDescriptor.fromBytes(await getBytesFromAsset("assets/icons/ic_onboard_address.png", 200));

    _mapPickUpMarker = Marker(
      markerId: _mapPickUpMarkerID,
      position: _pickUpLocation,
      draggable: false,
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset("assets/icons/ic_onboard_pick_up.png", 200)),
    );

    _mapDestinationMarker = Marker(
      markerId: _mapDestinationMarkerID,
      position: _pickUpLocation,
      draggable: false,
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset("assets/icons/ic_onboard_destination.png", 200)),
    );

    _mapAgentMarker = Marker(
      markerId: _mapAgentMarkerID,
      position: _pickUpLocation,
      draggable: false,
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset("assets/icons/ic_car_top_view.png", 80)),
      anchor: const Offset(0.5, 0.5),
      flat: true,
    );
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  PickUpState get pickUpState => _pickUpState;

  set pickUpState(PickUpState value) {
    if (_pickUpState != value) {
      _pickUpState = value;
      AppBlocs().pickUpController?.sink.add(_pickUpState);
    }
  }

  set pickUpLocation(LatLng value) {
    _pickUpLocation = value;
    if (_markers.length > 1) {
      _markers.clear();
    }

    Marker updatedPickUpMarker = _mapPickUpMarker.copyWith(
      positionParam: _pickUpLocation,
    );
    _markers[_mapPickUpMarkerID] = updatedPickUpMarker;
    pickUpState = PickUpState.searching;
    sinkStreamController();
  }

  LatLng get pickUpLocation => _pickUpLocation;

  set pickUpRoutePoint(RoutePoint value) {
    if (_pickUpRoutePoint != value) {
      _pickUpRoutePoint = value;
      Marker updatedPickUpMarker = _mapPickUpMarker.copyWith(
        positionParam: _pickUpRoutePoint.getLocation(),
      );
      _markers[_mapPickUpMarkerID] = updatedPickUpMarker;
    }
  }

  RoutePoint get pickUpRoutePoint => _pickUpRoutePoint;

  Set<Marker> markers() {
    return Set<Marker>.of(_markers.values);
  }

  Set<Polyline> polylines() {
    return Set<Polyline>.of(_polylines.values);
  }

  void sinkStreamController() {
    getMapPolyline();
    _mapMarkerSink.add(markers());
  }

  void addAgentLocation(MainLocation newLocation) {
    if (MainApplication().curOrder.agent == null) {
      clearAgentMarker();
      return;
    }
    /*
    DebugPrint().flog("_agentLocations.isEmpty = ${_agentLocations.isEmpty}");
    if (_agentLocations.isEmpty){
      DebugPrint().flog("newLocation.regDate = ${newLocation.regDate}");
      DebugPrint().flog("_lastAgentLocation.regDate = ${_lastAgentLocation.regDate}");
      if (newLocation.isAfter(_lastAgentLocation)){
        _agentLocations.add(newLocation);
      }
    }
    else if (newLocation.isAfter(_agentLocations.first)){
      _agentLocations.add(newLocation);
      _agentLocations.sort((a, b) => a.regDate.compareTo(b.regDate));
    }

     */
    _agentLocations.add(newLocation);


    if (!_agentLocationAnimate) {
      _animateAgentLocation();
    }
  }

  void _animateAgentLocation() {
    if (_agentLocations.isEmpty) return;
    _agentLocationAnimate = true;

    MainLocation newAgentLocation = _agentLocations.first;

    if (!_lastAgentLocation.isSame(newAgentLocation)) {
      Marker updatedPickUpMarker = _mapAgentMarker.copyWith(
        positionParam: newAgentLocation.toLatLng(),
        rotationParam: newAgentLocation.bearing == 0.0 ? newAgentLocation.calcBearing(_lastAgentLocation) : newAgentLocation.bearing,
      );

      _markers[_mapAgentMarkerID] = updatedPickUpMarker;
      _lastAgentLocation = newAgentLocation;
      sinkStreamController();
    }

    _agentLocations.removeAt(0);
    _agentLocationAnimate = false;
  }

  void agentMarkerRefresh(MainLocation agentLocation) {
    if (MainApplication().curOrder.agent == null) {
      clearAgentMarker();
      return;
    }

    if (!_lastAgentLocation.isSame(agentLocation)) {
      Marker updatedPickUpMarker = _mapAgentMarker.copyWith(
        positionParam: agentLocation.toLatLng(),
        rotationParam: agentLocation.bearing == 0.0 ? agentLocation.calcBearing(_lastAgentLocation) : agentLocation.bearing,
      );

      _markers[_mapAgentMarkerID] = updatedPickUpMarker;
      _lastAgentLocation = agentLocation;
      sinkStreamController();
    }
  }

  void clearAgentMarker({bool sink = true}) {
    if (_markers[_mapAgentMarkerID] != null) {
      _markers.remove(_mapAgentMarkerID);
    }
    _lastAgentLocation = MainLocation.nullable();
    _agentLocations.clear();
    if (sink) sinkStreamController();
  }

  Future<void> getMapPolyline() async {
    if (MainApplication().curOrder.routePoints.length > 1 && lastRoutePointPolylineData != MainApplication().curOrder.routePoints.toString()) {
      lastRoutePointPolylineData = MainApplication().curOrder.routePoints.toString();
      bool res = await _getMapPolylineRest(false);
      if (!res){
        await _getMapPolylineRest(true);
      }
      _mapMarkerSink.add(markers());
    } else if ((MainApplication().curOrder.routePoints.length == 1 || MainApplication().curOrder.routePoints.isEmpty) && _polylines.isNotEmpty) {
      // если точка маршрута одна, то очистить данные
      _polylines.clear();
      _mapMarkerSink.add(markers());
    }
  }

  Future<bool> _getMapPolylineRest(bool force) async {
    try {
      List<String>? polylineData = await GeoService().directions(jsonEncode(MainApplication().curOrder.routePoints), force: force);
      if (polylineData != null) {
        List<LatLng> polylineCoordinates = [];
        _polylines.clear();
        for (var polylineString in polylineData) {
          List<PointLatLng> polylinePointLatLng = PolylinePoints().decodePolyline(polylineString);
          for (var polylinePointLatLngPoint in polylinePointLatLng) {
            polylineCoordinates.add(LatLng(polylinePointLatLngPoint.latitude, polylinePointLatLngPoint.longitude));
          }
        }
        PolylineId id = const PolylineId("poly");
        Polyline polyline = Polyline(polylineId: id, color: mainColor, points: polylineCoordinates, width: 4);

        _polylines[id] = polyline;

      }
      return true;
    }
    catch (exception){
      return false;
    }
    return false;
  }

  void refresh() {
    clearAgentMarker(sink: false);
    lastRoutePointPolylineData = "";
    if (MainApplication().curOrder.orderState == OrderState.newOrder) {
      RoutePoint? pickUpRoutePoint = MainApplication().curOrder.routePoints.first;
      Marker updatedPickUpMarker = _mapPickUpMarker.copyWith(
        positionParam: pickUpRoutePoint.getLocation(),
      );
      _markers[_mapPickUpMarkerID] = updatedPickUpMarker;
    } else if (MainApplication().curOrder.orderState == OrderState.newOrderCalculating ||
        MainApplication().curOrder.orderState == OrderState.newOrderCalculated) {
      _markers.clear();
      if (MainApplication().curOrder.routePoints.length > 2) {
        for (int index = 1; index < (MainApplication().curOrder.routePoints.length - 1); index++) {
          RoutePoint routePoint = MainApplication().curOrder.routePoints[index];
          MarkerId markerId = MarkerId(routePoint.placeId);
          Marker marker = Marker(markerId: markerId, position: routePoint.getLocation(), draggable: false, icon: _mapAddressIcon);
          _markers[markerId] = marker;
        }
      }
      RoutePoint pickUpRoutePoint = MainApplication().curOrder.routePoints.first;
      Marker updatedPickUpMarker = _mapPickUpMarker.copyWith(
        positionParam: pickUpRoutePoint.getLocation(),
      );
      _markers[_mapPickUpMarkerID] = updatedPickUpMarker;

      RoutePoint destinationRoutePoint = MainApplication().curOrder.routePoints.last;
      Marker updatedDestinationMarker = _mapDestinationMarker.copyWith(
        positionParam: destinationRoutePoint.getLocation(),
      );
      _markers[_mapDestinationMarkerID] = updatedDestinationMarker;
    } // else if (AppStateProvider().curOrder.orderState == OrderState.new_order_calculating || AppStateProvider().curOrder.orderState == OrderState.new_order_calculated) {
    else {
      _markers.clear();

      if (MainApplication().curOrder.routePoints.length > 2) {
        for (int index = 1; index < (MainApplication().curOrder.routePoints.length - 1); index++) {
          RoutePoint routePoint = MainApplication().curOrder.routePoints[index];
          MarkerId markerId = MarkerId(routePoint.placeId);
          Marker marker = Marker(markerId: markerId, position: routePoint.getLocation(), draggable: false, icon: _mapAddressIcon);
          _markers[markerId] = marker;
        }
      }

      RoutePoint pickUpRoutePoint = MainApplication().curOrder.routePoints.first;
      Marker? updatedPickUpMarker = _mapPickUpMarker.copyWith(
        positionParam: pickUpRoutePoint.getLocation(),
      );
      _markers[_mapPickUpMarkerID] = updatedPickUpMarker;

      RoutePoint destinationRoutePoint = MainApplication().curOrder.routePoints.last;
      Marker updatedDestinationMarker = _mapDestinationMarker.copyWith(
        positionParam: destinationRoutePoint.getLocation(),
      );
      _markers[_mapDestinationMarkerID] = updatedDestinationMarker;

      if (MainApplication().curOrder.agent != null) {
        agentMarkerRefresh(MainApplication().curOrder.agent!.location);
        // addAgentLocation(MainApplication().curOrder.agent!.location);
      }
    } // else if (MainApplication().curOrder.orderState == OrderState.client_in_car){

    sinkStreamController();
  }

  LatLngBounds get _agentDestinationBounds {
    List<Marker> list = [];
    if (_markers[_mapDestinationMarkerID] != null) list.add(_markers[_mapDestinationMarkerID]!);
    if (_markers[_mapAgentMarkerID] != null) {
      list.add(_markers[_mapAgentMarkerID]!);
    } else {
      list.add(_markers[_mapPickUpMarkerID]!);
    }
    return calcBounds(list);
  }

  LatLngBounds get _agentPickUpBounds {
    List<Marker> list = [];
    if (_markers[_mapPickUpMarkerID] != null) list.add(_markers[_mapPickUpMarkerID]!);
    if (_markers[_mapAgentMarkerID] != null) {
      list.add(_markers[_mapAgentMarkerID]!);
    } else {
      list.add(_markers[_mapPickUpMarkerID]!);
    }

    return calcBounds(list);
  }

  LatLngBounds mapBounds() {
    if (MainApplication().curOrder.orderState == OrderState.driveToClient) return _agentPickUpBounds;
    if (MainApplication().curOrder.orderState == OrderState.driveAtClient) return _agentPickUpBounds;
    if (MainApplication().curOrder.orderState == OrderState.paidIdle) return _agentPickUpBounds;
    if (MainApplication().curOrder.orderState == OrderState.clientInCar) return _agentDestinationBounds;

    return calcBounds(List<Marker>.of(_markers.values));
  }

  LatLngBounds calcBounds(List<Marker> list) {
    assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (Marker marker in list) {
      if (x0 == null) {
        x0 = x1 = marker.position.latitude;
        y0 = y1 = marker.position.longitude;
      } else {
        if (marker.position.latitude > x1!) x1 = marker.position.latitude;
        if (marker.position.latitude < x0) x0 = marker.position.latitude;
        if (marker.position.longitude > y1!) y1 = marker.position.longitude;
        if (marker.position.longitude < y0!) y0 = marker.position.longitude;
      }
    }
    x1 = (x1! + (x1 - x0!) * 0.15);
    x0 = x0 - (x1 - x0) * 1.3;
    return LatLngBounds(northeast: LatLng(x1, y1!), southwest: LatLng(x0, y0!));
  }
}
