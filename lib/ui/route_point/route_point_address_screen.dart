import 'package:booking/constants/style.dart';
import 'package:booking/data/route_point.dart';
import 'package:booking/services/app_blocs.dart';
import 'package:booking/services/debug_print.dart';
import 'package:booking/services/geo_service.dart';
import 'package:booking/ui/route_point/route_point_search_bar.dart';
import 'package:booking/ui/route_point/route_point_text_field.dart';
import 'package:flutter/material.dart';

class RoutePointAddressScreen extends StatelessWidget {
  final String TAG = "RoutePointAddressScreen"; // ignore: non_constant_identifier_names
  final RoutePoint routeStreet;

  const RoutePointAddressScreen({super.key, required this.routeStreet});

  @override
  Widget build(BuildContext context) {
    RoutePointTextField? numberRoutePointTextField, splashRoutePointTextField;
    FocusNode textSecondFocusNode = FocusNode();
    RoutePointSearchBar routePointSearchBar = RoutePointSearchBar(
      hintText: routeStreet.name,
      enabled: false,
    );

    numberRoutePointTextField = RoutePointTextField(
      hintText: "Номер дома",
      onChanged: (value) => _autocompleteStreetAddress(routeStreet, numberRoutePointTextField, splashRoutePointTextField),
      autoFocus: true,
      onSubmitted: (value) => FocusScope.of(context).requestFocus(textSecondFocusNode),
    );
    splashRoutePointTextField = RoutePointTextField(
      hintText: "Строение/корпус",
      onChanged: (value) => _autocompleteStreetAddress(routeStreet, numberRoutePointTextField, splashRoutePointTextField),
      focusNode: textSecondFocusNode,
    );
    // _autocompleteStreetAddress(routeStreet, numberRoutePointTextField, splashRoutePointTextField);
    GeoService().autocompleteStreetAddress(routeStreet).then((result) {
      if (result == null) {
        List<RoutePoint> listRoutePoints = [];
        listRoutePoints.add(routeStreet);
        AppBlocs().geoAutocompleteAddressController?.sink.add(listRoutePoints);
      } else {
        AppBlocs().geoAutocompleteAddressController?.sink.add(result);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: routePointSearchBar,
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: numberRoutePointTextField,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: splashRoutePointTextField,
                  ),
                ),
              ],
            ),
            StreamBuilder(
              stream: AppBlocs().geoAutocompleteAddressStream,
              builder: (context, snapshot) {
                if (snapshot.data == "searching_") {
                  return const Center(
                    child: CircularProgressIndicator(backgroundColor: mainColor),
                  );
                }
                if (snapshot.data == "not_found_") {
                  return const Center(child: Text("Ничего не найдено"));
                }
                if (snapshot.data == null) {
                  return Container();
                }
                List<RoutePoint> routePoints = snapshot.data;
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: routePoints.length,
                  itemBuilder: (BuildContext context, int index) {
                    RoutePoint routePoint = routePoints.elementAt(index);
                    return ListTile(
                      title: Text(routePoint.name),
                      subtitle: Text(routePoint.dsc),
                      leading: routePoint.getIcon(),
                      onTap: () async {
                        if (routePoint.needDetail) {
                          GeoService().detail(routePoint).then((routePoint) {
                            Navigator.pop(context, routePoint);
                          });
                        } else {
                          Navigator.pop(context, routePoint);
                        }
                      },
                    );
                  },
                  // separatorBuilder: (BuildContext context, int index) => Divider(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _autocompleteStreetAddress(RoutePoint route, RoutePointTextField? numberRoutePointTextField, RoutePointTextField? splashRoutePointTextField) {
    String number = "", splash = "";
    if (numberRoutePointTextField != null) {
      number = numberRoutePointTextField.value;
    }
    if (splashRoutePointTextField != null) {
      splash = splashRoutePointTextField.value;
    }

    AppBlocs().geoAutocompleteAddressController?.sink.add("searching_");
    GeoService().autocompleteAddress(route, number, splash).then((result) {
      if (result == null) {
        List<RoutePoint> listRoutePoints = [];
        listRoutePoints.add(route);
        AppBlocs().geoAutocompleteAddressController?.sink.add(listRoutePoints);
      } else {
        AppBlocs().geoAutocompleteAddressController?.sink.add(result);
      }
    }).catchError((e) {
      DebugPrint().log(TAG, "_autocomplete address catchError", e.toString());
    });
  }
}
