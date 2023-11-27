import 'package:booking/constants/style.dart';
import 'package:flutter/material.dart';

import '../../../models/main_application.dart';
import '../../../models/order_state.dart';
import '../../../models/order_tariff.dart';

class NewOrderCalcTariffWidget extends StatelessWidget {
  OrderTariff orderTariff = OrderTariff(type: "economy");

  NewOrderCalcTariffWidget(OrderTariff? orderTariff, {super.key}) {
    if (orderTariff != null) {
      this.orderTariff = orderTariff;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 10.0, top: 0, bottom: 1),
        child: MaterialButton(
          onPressed: () {
            MainApplication().curOrder.selectedOrderTariff = orderTariff.type;
          },
          shape: orderTariff.selected
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: mainColor, width: 2),
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
          padding: const EdgeInsets.only(right: 8),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Image.asset(
                  orderTariff.iconName,
                  width: 70,
                ),
                Text(orderTariff.name),
                MainApplication().curOrder.orderState == OrderState.newOrderCalculating
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          backgroundColor: mainColor,
                          strokeWidth: 2.0,
                        ),
                      )
                    : SizedBox(
                        height: 18,
                        width: 70,
                        child: Text(
                          "${orderTariff.price} \u20BD",
                          textAlign: TextAlign.center,
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
