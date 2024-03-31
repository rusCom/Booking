import 'dart:ui' as ui;

import 'package:booking/data/main_location.dart';
import 'package:booking/services/map_markers_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AgentMarkerService {
  static final AgentMarkerService _instance = AgentMarkerService._internal();
  final MarkerId _mapAgentMarkerID = const MarkerId('_mapAgentMarkerID');
  late Marker _mapAgentMarker;
  late TickerProvider tickerProvider;
  List<MainLocation> locations = [];
  bool isAnimating = false;

  factory AgentMarkerService() {
    return _instance;
  }

  AgentMarkerService._internal();

  init(BuildContext context) async {
    _mapAgentMarker = Marker(
      markerId: _mapAgentMarkerID,
      position: const LatLng(0, 0),
      draggable: false,
      icon: BitmapDescriptor.fromBytes(
          await getBytesFromAsset("assets/icons/ic_car_top_view.png", 70)),
      anchor: const Offset(0.5, 0.5),
      flat: true,
    );
  }

  void addLocationJSON(Map<String, dynamic> newLocationJSON){
    addLocation(MainLocation.fromJson(newLocationJSON));
  }

  void addLocation(MainLocation newLocation) {
    if (newLocation.regDate.isAfter(locations[0].regDate)) {
      locations.add(newLocation);
      locations.sort((a, b) => a.regDate.compareTo(b.regDate));
    }
    animateMarker();
  }

  void animateMarker() {
    if (!isAnimating){
      isAnimating = true;



      // MapMarkersService().setMarker(markerId, marker)



      isAnimating = false;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
