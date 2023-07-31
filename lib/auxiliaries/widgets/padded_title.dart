import 'package:flutter/material.dart';

Widget paddedUnderlinedTitle(String title, double width) {
  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: width,
          decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black.withOpacity(0.5))),
        )
      ],
    ),
  );
}
