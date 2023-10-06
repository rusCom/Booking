import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../../models/main_application.dart';
import '../../../models/order.dart';
import '../../../models/order_state.dart';

class OrderSlidingPanelCaption extends StatelessWidget {
  String getTitle() {
    switch (MainApplication().curOrder.orderState) {
      case OrderState.searchCar:
        return "Поиск машины";
      case OrderState.driveToClient:
        return "К Вам едет";
      case OrderState.driveAtClient:
        return "Вас ожидает";
      case OrderState.paidIdle:
        return "Платный простой";
      case OrderState.clientInCar:
        return "В пути";
      default:
        return "Не известный статус";
    }
  }

  String getSubTitle() {
    switch (MainApplication().curOrder.orderState) {
      case OrderState.searchCar:
        return "Подбираем автомобиль на ваш заказ";
      default:
        final agent = MainApplication().curOrder.agent;
        if (agent != null) {
          return agent.car;
        } else {
          return "";
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.all(Radius.circular(12.0))),
            ),
          ],
        ),
        SizedBox(
          height: 18.0,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getTitle(),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              MainApplication().curOrder.orderState == OrderState.searchCar
                  ? JumpingDotsProgressIndicator(
                      fontSize: 20.0,
                    )
                  : Container(),
            ],
          ),
        ),
        Center(
          child: Text(getSubTitle()),
        ),
      ],
    );
  }
}
