import 'package:booking/ui/utils/core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import '../services/app_blocs.dart';

class RoutePoint {
  final String name;
  final String dsc;
  final double lt;
  final double ln;
  final String type;
  final String placeId;
  final bool needDetail;
  final List<String> notes;
  Key key = ValueKey(const Uuid().v1());
  String _note = "";
  bool canPickUp;

  RoutePoint(
      {this.name = "",
      this.dsc = "",
      this.lt = 0.0,
      this.ln = 0.0,
      this.type = "",
      this.placeId = "",
      this.needDetail = false,
      this.canPickUp = false,
      this.notes = const [],
      note = ""}) {
    key = ValueKey(const Uuid().v1());
    _note = note;
  }

  factory RoutePoint.fromJson(Map<String, dynamic> jsonData) {
    return RoutePoint(
      name: jsonData['name'] ?? "",
      dsc: jsonData['dsc'] ?? "",
      note: jsonData['note'] ?? "",
      lt: double.tryParse(jsonData['lt'].toString()) ?? 0,
      ln: double.tryParse(jsonData['ln'].toString()) ?? 0,
      needDetail: MainUtils.parseBool(jsonData['need_detail']),
      type: jsonData['type'] ?? "",
      placeId: jsonData['place_id'] ?? "",
      notes: jsonData['notes'] != null ? jsonData['notes'].cast<String>() : [],
      canPickUp: MainUtils.parseBool(jsonData['pick_up']),
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
      notes: routePoint.notes,
      canPickUp: routePoint.canPickUp,
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
    return _note;
  }

  bool get isNoteSet {
    if (_note == "") return false;
    if (_note == "Подъезд") return false;
    if (_note == "подъезд") return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "name": name,
        "dsc": dsc,
        "type": type,
        "lt": lt.toString(),
        "ln": ln.toString(),
        "note": note,
      };

  @override
  String toString() {
    return toJson().toString();
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
