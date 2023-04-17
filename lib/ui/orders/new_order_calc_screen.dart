import 'package:booking/ui/utils/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';

import '../../models/main_application.dart';
import '../../models/order.dart';
import '../../models/preferences.dart';
import '../../models/route_point.dart';
import '../../services/app_blocs.dart';
import '../../services/map_markers_service.dart';
import '../route_point/route_point_screen.dart';
import 'bottom_sheets/order_modal_bottom_sheets.dart';
import 'widgets/new_order_calc_main_button.dart';
import 'widgets/new_order_calc_tariff_check_widget.dart';
import 'widgets/new_order_route_points_reorder_dialog.dart';

class NewOrderCalcScreen extends StatelessWidget {
  final NewOrderMainButton newOrderMainButton = const NewOrderMainButton();

  const NewOrderCalcScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          bottom: 68,
          left: 0,
          right: 0,
          child: Container(
            constraints: const BoxConstraints(minWidth: double.infinity),
            margin: const EdgeInsets.only(left: 8, right: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder(
                      stream: AppBlocs().newOrderTariffStream,
                      builder: (context, snapshot) {
                        return NewOrderCalcTariffCheckWidget();
                      }),
                  ListTileMoreCustomizable(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.asset("assets/icons/ic_onboard_pick_up.png"),
                    ),
                    title: StreamBuilder(
                      stream: AppBlocs().orderStateStream,
                      builder: (context, snapshot) {
                        return Text(MainApplication().curOrder.routePoints.first.name,
                            style: const TextStyle(fontSize: 15), overflow: TextOverflow.ellipsis);
                      },
                    ),
                    trailing: SizedBox(
                      width: 110,
                      height: 40,
                      child: TextButton(
                        onPressed: () async {
                          if (MainApplication().curOrder.routePoints.first.notes.isNotEmpty) {
                            OrderModalBottomSheets.orderNotes(context);
                          } else {
                            OrderModalBottomSheets.orderNote(context);
                          }
                        },
                        child: StreamBuilder(
                            stream: AppBlocs().newOrderNoteStream,
                            builder: (context, snapshot) {
                              return Text(
                                MainApplication().curOrder.routePoints.first.note,
                                style: const TextStyle(fontSize: 15, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              );
                            }),
                      ),
                    ),
                    horizontalTitleGap: 0.0,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
                  ),
                  ListTileMoreCustomizable(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Image.asset("assets/icons/ic_onboard_destination.png"),
                    ),
                    title: StreamBuilder(
                      stream: AppBlocs().orderStateStream,
                      builder: (context, snapshot) {
                        return Text(
                          MainApplication().curOrder.getLastRouteName(),
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    subtitle: StreamBuilder(
                      stream: AppBlocs().orderStateStream,
                      builder: (context, snapshot) {
                        return Text(
                          MainApplication().curOrder.getLastRouteDsc(),
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        if (MainApplication().curOrder.orderState == OrderState.new_order_calculated) {
                          if (MainApplication().curOrder.routePoints.length == 2) {
                            RoutePoint? routePoint =
                                await Navigator.push<RoutePoint>(context, MaterialPageRoute(builder: (context) => const RoutePointScreen()));
                            if (routePoint != null) {
                              MainApplication().curOrder.addRoutePoint(routePoint);
                            }
                          } else {
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => NewOrderRoutePointsReorderDialog()));
                            MainApplication().curOrder.calcOrder();
                          }
                        }
                      },
                    ),
                    horizontalTitleGap: 0.0,
                    onTap: (details) async {
                      if (MainApplication().curOrder.orderState == OrderState.new_order_calculated) {
                        if (MainApplication().curOrder.routePoints.length == 2) {
                          RoutePoint? routePoint = await Navigator.push<RoutePoint>(
                              context, MaterialPageRoute(builder: (context) => const RoutePointScreen(viewReturn: false)));
                          if (routePoint != null) {
                            MainApplication().curOrder.addRoutePoint(routePoint, isLast: true);
                          }
                        } else {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => NewOrderRoutePointsReorderDialog()));
                          MainApplication().curOrder.calcOrder();
                        }
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  Divider(
                    color: Preferences().mainColor,
                    indent: 15,
                    endIndent: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder(
                          stream: AppBlocs().newOrderPaymentStream,
                          builder: (context, snapshot) {
                            return TextButton.icon(
                              icon: SvgPicture.asset(
                                MainApplication().curOrder.paymentType().iconName,
                                width: 32,
                                height: 32,
                                colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
                              ),
                              label: Text(MainApplication().curOrder.paymentType().name,
                                  overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black)),
                              onPressed: () {
                                if (MainApplication().curOrder.paymentTypes.length > 1) {
                                  OrderModalBottomSheets.paymentTypes(context);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 40, child: VerticalDivider(color: Preferences().mainColor)),
                      Expanded(
                        child: TextButton.icon(
                          icon: StreamBuilder(
                              stream: AppBlocs().newOrderWishesStream,
                              builder: (context, snapshot) {
                                return wishesCount();
                              }),
                          label: const Text("Пожелания", style: TextStyle(color: Colors.black)),
                          onPressed: () => OrderModalBottomSheets.orderWishes(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        newOrderMainButton,
        Positioned(
          bottom: 340,
          right: 8,
          child: FloatingActionButton(
            heroTag: '_mapBounds',
            backgroundColor: Colors.white,
            onPressed: mapBounds,
            child: const Icon(
              Icons.near_me,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          bottom: 340,
          left: 8,
          child: FloatingActionButton(
            heroTag: '_backPressed',
            backgroundColor: Colors.white,
            onPressed: backPressed,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget wishesCount() {
    if (MainApplication().curOrder.orderWishes.countWithOutWorkDate == 0) {
      return SvgPicture.asset(
        "assets/icons/ic_wishes.svg",
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
      );
    }
    return ClipOval(
      child: Container(
        color: Preferences().mainColor,
        height: 24,
        width: 24,
        child: Center(
          child: Text(
            MainApplication().curOrder.orderWishes.countWithOutWorkDate.toString(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  void backPressed() {
    if (MainApplication().curOrder.orderState == OrderState.new_order_calculated) {
      LatLng location = MainApplication().curOrder.routePoints.first.getLocation();
      MainApplication().curOrder.orderState = OrderState.new_order;
      MapMarkersService().pickUpLocation = location;

      MainApplication().mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: location,
                zoom: 17.0,
              ),
            ),
          );
    }
  }

  void mapBounds() {
    MainApplication().mapController?.animateCamera(CameraUpdate.newLatLngBounds(MapMarkersService().mapBounds(), Preferences().systemMapBounds));
  }
}
