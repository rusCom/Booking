import 'package:booking/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/core.dart';
import 'order_wishes_title.dart';

typedef OrderWishesDriverNoteChangeCallback = void Function(String value);

class OrderWishesDriverNote extends StatefulWidget {
  final String value;
  final OrderWishesDriverNoteChangeCallback onChanged;

  const OrderWishesDriverNote({super.key, required this.value, required this.onChanged});

  @override
  _OrderWishesDriverNoteState createState() => _OrderWishesDriverNoteState();
}

class _OrderWishesDriverNoteState extends State<OrderWishesDriverNote> {
  late String value;

  @override
  Widget build(BuildContext context) {
    value = widget.value;
    return ListTile(
      leading: SvgPicture.asset(
        "assets/icons/ic_wishes_driver_note.svg",
        height: Const.modalBottomSheetsLeadingSize,
        width: Const.modalBottomSheetsLeadingSize,
      ),
      title: value == "" ? const Text("Комментарий водителю") : Text(value),
      subtitle: value == "" ? null : const Text("Комментарий водителю"),
      onTap: () async {
        String newValue = await orderWishesDriverNote(context, value);
        setState(() {
          widget.onChanged(newValue);
                  value = newValue;
        });
      },
      trailing: IconButton(
        icon: Icon(value == "" ? Icons.keyboard_arrow_right : Icons.clear),
        onPressed: () async {
          if (value == "") {
            String newValue = await orderWishesDriverNote(context, value);
            setState(() {
              widget.onChanged(newValue);
                          value = newValue;
            });
          } else {
            setState(() {
              widget.onChanged("");
                          value = "";
            });
          }
        },
      ),
    );
  }

  static Future<String> orderWishesDriverNote(BuildContext context, String driverNote) async {
    final noteController = TextEditingController(text: driverNote);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 8, right: 8, top: 16),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              // bottomSheetTitle(context, "Комментарий водителю"),
              const OrderWishesTitle("Комментарий водителю"),
              TextField(
                autofocus: true,
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                },
                controller: noteController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ваш комментарий для водителя',
                  icon: SvgPicture.asset(
                    "assets/icons/ic_wishes_driver_note.svg",
                    height: Const.modalBottomSheetsLeadingSize,
                    width: Const.modalBottomSheetsLeadingSize,
                    color: const Color(0xFF757575),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: MaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  splashColor: Colors.yellow[200],
                  textColor: Colors.white,
                  color: mainColor,
                  disabledColor: Colors.grey,
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    "Готово",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        );
      },
    );
    return noteController.value.text;
  }
}
