import 'package:booking/constants/style.dart';
import 'package:booking/data/main_application.dart';
import 'package:booking/data/order_baby_seats.dart';
import 'package:booking/data/preferences.dart';
import 'package:booking/ui/orders/wishes/order_wishes_title.dart';
import 'package:booking/ui/utils/core.dart';
import 'package:booking/ui/widgets/number_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


typedef OrderWishesBabySeatsChangeCallback = void Function(OrderBabySeats value);

class OrderWishesBabySeats extends StatefulWidget {
  final OrderBabySeats orderBabySeats;
  final OrderWishesBabySeatsChangeCallback onChanged;

  const OrderWishesBabySeats({super.key, required this.orderBabySeats, required this.onChanged});

  @override
  _OrderWishesBabySeatsState createState() => _OrderWishesBabySeatsState();
}

class _OrderWishesBabySeatsState extends State<OrderWishesBabySeats> {
  late OrderBabySeats orderBabySeats;

  @override
  Widget build(BuildContext context) {
    orderBabySeats = widget.orderBabySeats;
    if (!MainApplication().curOrder.orderTariff.wishesBabySeats) return Container();
    return ListTile(
      leading: SvgPicture.asset(
        "assets/icons/ic_wishes_baby_seats.svg",
        height: Const.modalBottomSheetsLeadingSize,
        width: Const.modalBottomSheetsLeadingSize,
      ),
      title: const Text("Детское кресло"),
      trailing: IconButton(
        icon: Icon(orderBabySeats.isClearButton ? Icons.clear : Icons.keyboard_arrow_right),
        onPressed: () async {
          if (orderBabySeats.isClearButton) {
            setState(() {
              orderBabySeats.clear();
              widget.onChanged(orderBabySeats);
            });
          } else {
            OrderBabySeats newOrderBabySeats = await orderWishesBabySeats(context, orderBabySeats);
            setState(() {
              orderBabySeats = newOrderBabySeats;
              widget.onChanged(newOrderBabySeats);
            });
          }
        },
      ),
      subtitle: orderBabySeats.subtitle,
      onTap: () async {
        OrderBabySeats newOrderBabySeats = await orderWishesBabySeats(context, orderBabySeats);
        setState(() {
          orderBabySeats = newOrderBabySeats;
          widget.onChanged(newOrderBabySeats);
        });
      },
    );
  }

  Future<OrderBabySeats> orderWishesBabySeats(BuildContext context, OrderBabySeats inOrderBabySeats) async {
    OrderBabySeats orderBabySeats = inOrderBabySeats;
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 8, right: 8, top: 16),
              child: Column(
                children: <Widget>[
                  const OrderWishesTitle("Детское кресло"),
                  ListTile(
                    title: const Text("Люлька"),
                    subtitle: const Text("до 10 кг"),
                    trailing: NumberCounter(
                      initialValue: orderBabySeats.babySeat0010,
                      minValue: 0,
                      maxValue: Preferences().wishesBabySeatsCount,
                      color: mainColor,
                      onChanged: (value) => stateSetter(() => orderBabySeats.babySeat0010 = value),
                    ),
                  ),
                  ListTile(
                    title: const Text("Кресло"),
                    subtitle: const Text("от 9 до 18 кг"),
                    trailing: NumberCounter(
                      initialValue: orderBabySeats.babySeat0918,
                      minValue: 0,
                      maxValue: Preferences().wishesBabySeatsCount,
                      color: mainColor,
                      onChanged: (value) => stateSetter(() => orderBabySeats.babySeat0918 = value),
                    ),
                  ),
                  ListTile(
                    title: const Text("Кресло"),
                    subtitle: const Text("от 15 до 25 кг"),
                    trailing: NumberCounter(
                      initialValue: orderBabySeats.babySeat1525,
                      minValue: 0,
                      maxValue: Preferences().wishesBabySeatsCount,
                      color: mainColor,
                      onChanged: (value) => stateSetter(() => orderBabySeats.babySeat1525 = value),
                    ),
                  ),
                  ListTile(
                    title: const Text("Бустер"),
                    subtitle: const Text("от 22 до 36 кг"),
                    trailing: NumberCounter(
                      initialValue: orderBabySeats.babySeat2236,
                      minValue: 0,
                      maxValue: Preferences().wishesBabySeatsCount,
                      color: mainColor,
                      onChanged: (value) => stateSetter(() => orderBabySeats.babySeat2236 = value),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    return orderBabySeats;
  }
}
