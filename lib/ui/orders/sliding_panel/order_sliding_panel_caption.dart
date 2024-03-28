import 'package:booking/data/main_application.dart';
import 'package:booking/data/order_state.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class OrderSlidingPanelCaption extends StatelessWidget {
  final OrderState orderState;
  const OrderSlidingPanelCaption({super.key, required this.orderState});

  String getTitle() {
    switch (orderState) {
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
    switch (orderState) {
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
        const SizedBox(
          height: 12.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: const BorderRadius.all(Radius.circular(12.0))),
            ),
          ],
        ),
        const SizedBox(
          height: 18.0,
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getTitle(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              orderState == OrderState.searchCar
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
