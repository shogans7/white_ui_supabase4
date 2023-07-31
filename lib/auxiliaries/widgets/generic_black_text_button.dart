import 'package:flutter/material.dart';

Widget genericButton(String buttonText, Function() onPressed) {
  return ElevatedButton(
    style: ButtonStyle(
      side: MaterialStateProperty.all(const BorderSide(width: 3)),
    ),
    onPressed: onPressed,
    child: Text(buttonText),
  );
}
