import 'package:flutter/material.dart';

import '../../models/preferences.dart';
import '../../models/route_point.dart';
import '../../services/app_blocs.dart';
import '../../services/geo_service.dart';
import '../utils/core.dart';
import 'route_point_search_bar.dart';
import 'route_point_text_field.dart';

class RoutePointAddressScreen extends StatelessWidget {
  final String TAG = "RoutePointAddressScreen"; // ignore: non_constant_identifier_names
  final RoutePoint routeStreet;

  const RoutePointAddressScreen({Key? key, required this.routeStreet}) : super(key: key);

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
      onChanged: (value) => _autocompleteStreetAddress(routeStreet.placeId, numberRoutePointTextField, splashRoutePointTextField),
      autoFocus: true,
      onSubmitted: (value) => FocusScope.of(context).requestFocus(textSecondFocusNode),
    );
    splashRoutePointTextField = RoutePointTextField(
      hintText: "Строение/корпус",
      onChanged: (value) => _autocompleteStreetAddress(routeStreet.placeId, numberRoutePointTextField, splashRoutePointTextField),
      focusNode: textSecondFocusNode,
    );
    _autocompleteStreetAddress(routeStreet.placeId, numberRoutePointTextField, splashRoutePointTextField);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: routePointSearchBar,
        backgroundColor: Preferences().mainColor,
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
                  return Center(
                    child: CircularProgressIndicator(backgroundColor: Preferences().mainColor),
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
                        if (routePoint.detail == '1') {
                          Navigator.pop(context, routePoint);
                        } else {
                          GeoService().detail(routePoint).then((routePoint) {
                            Navigator.pop(context, routePoint);
                          });
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

  _autocompleteStreetAddress(String route, RoutePointTextField? numberRoutePointTextField, RoutePointTextField? splashRoutePointTextField) {
    String number = "", splash = "";
    if (numberRoutePointTextField != null) {
      number = numberRoutePointTextField.value;
    }
    if (splashRoutePointTextField != null) {
      splash = splashRoutePointTextField.value;
    }
    if (route.isNotEmpty && route != "") {
      AppBlocs().geoAutocompleteAddressController?.sink.add("searching_");
      GeoService().autocompleteHouse(route, number, splash)!.then((result) {
        if (result == null)
          AppBlocs().geoAutocompleteAddressController?.sink.add("not_found_");
        else {
          AppBlocs().geoAutocompleteAddressController?.sink.add(result);
        }
      }).catchError((e) {
        DebugPrint().log(TAG, "_autocomplete address catchError", e.toString());
      });
    } else {
      AppBlocs().geoAutocompleteAddressController?.sink.add("null_");
    }
  }
}
