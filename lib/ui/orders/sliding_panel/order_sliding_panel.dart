import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../models/order.dart';
import '../../../models/route_point.dart';
import '../../utils/core.dart';
import '../bottom_sheets/order_modal_bottom_sheets.dart';
import 'order_sliding_panel_bottom.dart';
import 'order_sliding_panel_caption.dart';
import 'order_sliding_panel_wishes_tile.dart';

class OrderSlidingPanel extends StatelessWidget {
  final Order curOrder;

  const OrderSlidingPanel({super.key, required this.curOrder});

  double getMaxHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.65;
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      minHeight: 100,
      maxHeight: getMaxHeight(context),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      borderRadius: BorderRadius.circular(18),
      panel: Column(
        children: <Widget>[
          OrderSlidingPanelCaption(orderState: curOrder.orderState),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    leading: SvgPicture.asset(
                      curOrder.paymentType()!.iconName,
                      width: Const.modalBottomSheetsLeadingSize,
                      height: Const.modalBottomSheetsLeadingSize,
                    ),
                    title: const Text("Стоимость поездки"),
                    subtitle: Text(curOrder.paymentType()!.choseName),
                    trailing: Text("${curOrder.price} \u20BD"),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: curOrder.routePoints.length,
                      itemBuilder: (BuildContext context, int index) {
                        RoutePoint routePoint = curOrder.routePoints[index];
                        String imageLocation = "assets/icons/ic_onboard_pick_up.png";
                        if (index == 0) {
                          String subtitle = "Указать подъезд";
                          String name = routePoint.name;
                          if (routePoint.isNoteSet) {
                            subtitle = routePoint.note;
                          }

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(imageLocation),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(name),
                            subtitle: Text(subtitle),
                            onTap: () async {
                              if (!routePoint.isNoteSet) {
                                String note = await OrderModalBottomSheets.orderNoteRes(context);
                                curOrder.note(note);
                              }
                            },
                          );
                        }
                        if (index == curOrder.routePoints.length - 1) {
                          imageLocation = "assets/icons/ic_onboard_destination.png";
                        } else {
                          imageLocation = "assets/icons/ic_onboard_address.png";
                        }
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(imageLocation),
                            backgroundColor: Colors.transparent,
                          ),
                          title: Text(routePoint.name),
                          subtitle: Text(routePoint.dsc),
                        );
                      },
                    ),
                  ),
                  OrderSlidingPanelWishesTile(curOrder.orderWishes),
                ],
              ),
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: OrderSlidingPanelBottom(curOrder: curOrder),
          ),
        ],
      ),
      collapsed: OrderSlidingPanelCaption(orderState: curOrder.orderState),
    );
  }
}
