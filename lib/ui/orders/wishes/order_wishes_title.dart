import 'package:flutter/material.dart';

class OrderWishesTitle extends StatelessWidget {
  final String title;

  const OrderWishesTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 4,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          iconSize: 30,
        ),
        const SizedBox(
          width: 16,
        ),
        Flexible(
          child: Text(
            title,
            // textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
      ],
    );
  }
}
