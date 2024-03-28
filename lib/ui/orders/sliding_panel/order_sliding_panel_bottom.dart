import 'package:booking/data/main_application.dart';
import 'package:booking/data/order.dart';
import 'package:flutter/material.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';


class OrderSlidingPanelBottom extends StatelessWidget {
  final Order curOrder;

  const OrderSlidingPanelBottom({super.key, required this.curOrder});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        curOrder.canDeny
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        _showDenyOrderDialog(context, curOrder);
                      },
                      heroTag: "_denyOrder",
                      child: const Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                    ),
                    const Center(
                      child: Text('Отменить'),
                    ),
                    const Center(
                      child: Text('поездку'),
                    ),
                  ],
                ),
              )
            : Container(),
        MainApplication().preferences.canDispatcherCall
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        MainApplication().launchURL("tel://${MainApplication().preferences.dispatcherPhone}");
                      },
                      heroTag: "_dispathcerCall",
                      child: const Icon(
                        Icons.call,
                        color: Colors.lightGreen,
                      ),
                    ),
                    const Center(
                      child: Text('Позвонить'),
                    ),
                    const Center(
                      child: Text('диспетчеру'),
                    ),
                  ],
                ),
              )
            : Container(),
        curOrder.agent != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {
                        MainApplication().launchURL("tel://${curOrder.agent?.phone}");
                      },
                      heroTag: "_agentCall",
                      child: const Icon(
                        Icons.phone_in_talk,
                        color: Colors.green,
                      ),
                    ),
                    const Center(
                      child: Text('Позвонить'),
                    ),
                    const Center(
                      child: Text('водителю'),
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }

  _showDenyOrderDialog(BuildContext context, Order curOrder) {
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        builder: (BuildContext bc) {
          return Container(
            color: const Color(0xFF737373),
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
              // margin: EdgeInsets.only(left: 8, right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTileMoreCustomizable(
                      title: const Text("Долгая подача автомобиля"),
                      onTap: (details) async {
                        await curOrder.deny("Долгая подача автомобиля");
                        if (context.mounted) Navigator.pop(context);
                      }),
                  ListTileMoreCustomizable(
                      title: const Text("Водитель попросил сделать отбой"),
                      onTap: (details) async {
                        await curOrder.deny("Водитель попросил сделать отбой");
                        if (context.mounted) Navigator.pop(context);
                      }),
                  ListTileMoreCustomizable(
                      title: const Text("Водитель не адекватный"),
                      onTap: (details) async {
                        await curOrder.deny("Водитель не адекватный");
                        if (context.mounted) Navigator.pop(context);
                      }),
                  ListTileMoreCustomizable(
                      title: const Text("Не указывать причину"),
                      onTap: (details) async {
                        await curOrder.deny("");
                        if (context.mounted) Navigator.pop(context);
                      }),
                  ListTileMoreCustomizable(
                      title: const Text("Не отменять поездку"),
                      onTap: (details) async {
                        Navigator.pop(context);
                      }),
                ],
              ),
            ),
          );
        });
  } // _showDenyOrderDialog
}
