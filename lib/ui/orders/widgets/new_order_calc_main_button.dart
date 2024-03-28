import 'package:booking/constants/style.dart';
import 'package:booking/data/main_application.dart';
import 'package:booking/data/order_state.dart';
import 'package:booking/services/app_blocs.dart';
import 'package:booking/ui/orders/bottom_sheets/order_modal_bottom_sheets.dart';
import 'package:flutter/material.dart';


class NewOrderMainButton extends StatelessWidget {
  const NewOrderMainButton({super.key});

  String getCaption() {
    if (MainApplication().curOrder.orderState == OrderState.newOrderCalculating) return "Расчёт стоимости ...";

    if (MainApplication().curOrder.orderWishes.workDate != null) {
      return "Запланировать поездку\n${MainApplication().curOrder.orderWishes.workDateCaption}";
    }

    return "Заказать";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: () => onMainButtonPressed(),
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                  padding: const EdgeInsets.all(8.0),
                ),
                child: StreamBuilder<OrderState>(
                    stream: AppBlocs().orderStateStream,
                    builder: (context, snapshot) {
                      return Text(
                        getCaption(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    }),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            width: 60,
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(bottomRight: Radius.circular(18)),
                  border: Border.all(color: mainColor, width: 2),
                  color: mainColor,
                ),
                child: const Icon(
                  Icons.date_range,
                  color: Colors.white,
                ),
              ),
              onTap: () => onDateButtonPressed(context),
            ),
          )
        ],
      ),
    );
  }

  void onDateButtonPressed(BuildContext context) {
    if (MainApplication().curOrder.orderState == OrderState.newOrderCalculated) {
      OrderModalBottomSheets.orderDate(context);
    }
  }

  void onMainButtonPressed() {
    if (MainApplication().curOrder.orderState == OrderState.newOrderCalculated) {
      MainApplication().curOrder.addOrder();
    }
  }
}
