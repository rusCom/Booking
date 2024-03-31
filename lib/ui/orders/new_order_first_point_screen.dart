import 'package:booking/constants/style.dart';
import 'package:booking/data/main_application.dart';
import 'package:booking/data/route_point.dart';
import 'package:booking/services/app_blocs.dart';
import 'package:booking/services/map_markers_service.dart';
import 'package:booking/services/rest_service.dart';
import 'package:booking/ui/route_point/route_point_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class NewOrderFirstPointScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final ValueChanged<RoutePoint>? onChanged;

  NewOrderFirstPointScreen({super.key, this.onChanged});

  void setText(String data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.text = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 55,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.transparent,
            constraints: const BoxConstraints(minWidth: double.infinity),
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: TextField(
                  readOnly: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ожидание GPS данных",
                    hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 16),
                    prefixIcon: const Icon(
                      Icons.add_location,
                      color: Color(0xFF757575),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color(0xFF757575),
                      ),
                      onPressed: () async {
                        RoutePoint? pickUpRoutePoint = await Navigator.push<RoutePoint>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RoutePointScreen(
                              isFirst: true,
                            ),
                          ),
                        );

                        if (pickUpRoutePoint != null) {
                          MainApplication().mapController?.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: pickUpRoutePoint.getLocation(),
                                    zoom: 17.0,
                                  ),
                                ),
                              );
                          // setPickUpRoutePoint(pickUpRoutePoint);
                        }
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                    fillColor: const Color(0xFFEEEEEE),
                    filled: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Container(
            constraints: const BoxConstraints(minWidth: double.infinity),
            alignment: Alignment.center,
            height: 60,
            width: double.infinity,
            // margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: StreamBuilder(
                  stream: AppBlocs().pickUpStream,
                  builder: (context, snapshot) {
                    return MaterialButton(
                      onPressed: () => MapMarkersService().pickUpState == PickUpState.enabled ? _mainButtonClick(context) : null,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
                      ),
                      splashColor: Colors.yellow[200],
                      textColor: Colors.white,
                      color: mainColor,
                      disabledColor: Colors.grey,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 40, child: Icon(Icons.find_replace)),
                          snapshot.data == PickUpState.disabled
                              ? const Expanded(
                                  child: Text(
                                    "Извините, регион не обслуживается",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const Text(
                                  "Куда?",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          right: 8,
          child: FloatingActionButton(
            heroTag: '_moveToCurLocation',
            backgroundColor: Colors.white,
            onPressed: () => MainApplication().curOrder.moveToCurLocation(),
            child: const Icon(
              Icons.near_me,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void onCameraMove(CameraPosition position) {
    MapMarkersService().pickUpLocation = position.target;

  }

  void setPickUpRoutePoint(RoutePoint routePoint) {
    if (routePoint != MapMarkersService().pickUpRoutePoint) {
      MapMarkersService().pickUpRoutePoint = routePoint;
      if (routePoint.type == "street_address") {
        setText(routePoint.name);
      } else {
        setText("${routePoint.name}, ${routePoint.dsc}");
      }
      if (routePoint.canPickUp) {
        MapMarkersService().pickUpState = PickUpState.enabled;
      } else {
        MapMarkersService().pickUpState = PickUpState.disabled;
      }
      MapMarkersService().pickUpRoutePoint = routePoint;
    }
  }

  void onCameraIdle() {
    RestService()
        .httpGet("/orders/pickup?lt=${MapMarkersService().pickUpLocation.latitude}&ln=${MapMarkersService().pickUpLocation.longitude}")
        .then((response) {
      if (response['status'] == 'OK') {
        RoutePoint routePoint = RoutePoint.fromJson(response['result']);
        setPickUpRoutePoint(routePoint);
      } else {
        MapMarkersService().pickUpState = PickUpState.disabled;
      }
    });
  }

  void _mainButtonClick(BuildContext context) async {
    RoutePoint? routePoint = await Navigator.push<RoutePoint>(context, MaterialPageRoute(builder: (context) => const RoutePointScreen()));
    if (routePoint != null) {
      MainApplication().curOrder.addRoutePoint(MapMarkersService().pickUpRoutePoint);
      MainApplication().curOrder.addRoutePoint(routePoint);
    }
  }
}
