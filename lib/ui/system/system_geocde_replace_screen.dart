import 'package:booking/data/route_point.dart';
import 'package:booking/services/debug_print.dart';
import 'package:booking/services/geo_service.dart';
import 'package:booking/ui/route_point/route_point_screen.dart';
import 'package:flutter/material.dart';


class SystemGeocodeReplaceScreen extends StatefulWidget {
  final RoutePoint fromRoutePoint;

  const SystemGeocodeReplaceScreen(this.fromRoutePoint, {super.key});

  @override
  _SystemGeocodeReplaceScreenState createState() => _SystemGeocodeReplaceScreenState();
}

class _SystemGeocodeReplaceScreenState extends State<SystemGeocodeReplaceScreen> {
  final TAG = (SystemGeocodeReplaceScreen).toString(); // ignore: non_constant_identifier_names
  late RoutePoint toRoutePoint;

  @override
  Widget build(BuildContext context) {
    DebugPrint().log(TAG, "build", widget.fromRoutePoint.toString());
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Заменить точку геокодинга"),
            Text("name: ${widget.fromRoutePoint.name}"),
            Text("dsc: ${widget.fromRoutePoint.dsc}"),
            Text("placeID: ${widget.fromRoutePoint.placeId}"),
            MaterialButton(
              onPressed: () async {
                RoutePoint? destinationRoutePoint =
                    await Navigator.push<RoutePoint>(context, MaterialPageRoute(builder: (context) => const RoutePointScreen()));
                if (destinationRoutePoint != null) {
                  setState(() {
                    toRoutePoint = destinationRoutePoint;
                    DebugPrint().log(TAG, "new point result = ", destinationRoutePoint.toString());
                  });
                }
              },
              child: const Text("Выбрать новую точку"),
            ),
            toRoutePoint != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("На следующую точку геокодинга"),
                      Text("name: ${toRoutePoint.name}"),
                      Text("dsc: ${toRoutePoint.dsc}"),
                      Text("placeID: ${toRoutePoint.placeId}"),
                      MaterialButton(
                        child: const Text("Заменить. Подумай, прежде чем нажать"),
                        onPressed: () async {
                          GeoService().geocodeReplace(widget.fromRoutePoint.placeId, toRoutePoint.placeId);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  )
                : Container(),
            MaterialButton(
              child: const Text("Очистить кэш по геокодингу для выбранной точки."),
              onPressed: () async {
                GeoService().geocodeClear(widget.fromRoutePoint);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
