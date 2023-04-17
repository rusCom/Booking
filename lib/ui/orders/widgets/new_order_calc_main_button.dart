import 'package:booking/ui/utils/core.dart';
import 'package:flutter/material.dart';

import '../../../models/main_application.dart';
import '../../../models/order.dart';
import '../../../models/preferences.dart';
import '../../../services/app_blocs.dart';
import '../bottom_sheets/order_modal_bottom_sheets.dart';

class NewOrderMainButton extends StatelessWidget {
  const NewOrderMainButton({super.key});

  String getCaption() {
    if (MainApplication().curOrder.orderState == OrderState.new_order_calculating) return "Расчет стоимости ...";
    /*
    if (MainApplication().curOrder.orderWishes.workDate != null) {
      return "Запланировать поездку\n${MainApplication().curOrder.orderWishes.workDateCaption}";
    }

     */
    return "Заказать такси";
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
                  backgroundColor: Preferences().mainColor,
                  disabledBackgroundColor: Colors.grey,
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
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(18)),
                ),
                backgroundColor: Preferences().mainColor,
                disabledBackgroundColor: Colors.grey,
              ),
              icon: const Icon(Icons.date_range),
              label: const Text(""),
              onPressed: () => onDateButtonPressed(context),
            ),
          )
        ],
      ),
    );
  }

  void onDateButtonPressed(BuildContext context) {
    if (MainApplication().curOrder.orderState == OrderState.new_order_calculated) {
      OrderModalBottomSheets.orderDate(context);
    }
  }

  void onMainButtonPressed() {
    if (MainApplication().curOrder.orderState == OrderState.new_order_calculated) {
      // MainApplication().curOrder.add();
      DebugPrint().flog("onMainButtonPressed addOrder");
    }
  }
}
