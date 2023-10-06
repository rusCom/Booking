import 'package:flutter/material.dart';
import '../../../models/main_application.dart';
import 'new_order_calc_tariff_widget.dart';

class NewOrderCalcTariffCheckWidget extends StatelessWidget {
  Widget _getOrderTariffContainer(String orderTariffName) {
    for (var searchOrderTariff in MainApplication().curOrder.orderTariffs) {
      if (searchOrderTariff.type == orderTariffName) {
        return NewOrderCalcTariffWidget(searchOrderTariff);
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 0, top: 3, right: 8),
      child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _getOrderTariffContainer("economy"),
                _getOrderTariffContainer("comfort"),
                _getOrderTariffContainer("business"),
                _getOrderTariffContainer("delivery"),
                _getOrderTariffContainer("sober_driver"),
                _getOrderTariffContainer("cargo"),
                _getOrderTariffContainer("express"),
              ],
            ),
          )),
    );
  }
}
