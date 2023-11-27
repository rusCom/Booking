import 'package:booking/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/core.dart';

typedef OrderWishesSwitchChangeCallback = void Function(bool value);

class OrderWishesSwitch extends StatefulWidget {
  final bool orderWishesValue;
  final bool viewSwitch;
  final String caption;
  final String svgAssets;
  final OrderWishesSwitchChangeCallback onChanged;

  const OrderWishesSwitch(
      {Key? key, required this.orderWishesValue, required this.caption, required this.onChanged, required this.viewSwitch, required this.svgAssets})
      : super(key: key);

  @override
  State<OrderWishesSwitch> createState() => _OrderWishesSwitchState();
}

class _OrderWishesSwitchState extends State<OrderWishesSwitch> {
  late bool orderWishesValue;

  @override
  void initState() {
    super.initState();
    orderWishesValue = widget.orderWishesValue;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.viewSwitch) return Container();

    return ListTile(
      leading: SvgPicture.asset(
        widget.svgAssets,
        height: Const.modalBottomSheetsLeadingSize,
        width: Const.modalBottomSheetsLeadingSize,
      ),
      title: Text(widget.caption),
      trailing: _switch(),
      onTap: () => setState(() {
        orderWishesValue = !orderWishesValue;
        widget.onChanged(orderWishesValue);
      }),
    );
  }

  Widget _switch() {
    return Switch(
        value: orderWishesValue,
        activeColor: mainColor,
        onChanged: (value) => setState(() {
              orderWishesValue = value;
              widget.onChanged(value);
            }));
  }
}
