import 'package:flutter/material.dart';

Widget emptyScreen(
    BuildContext context,
    String promptText,
    // Color promptColor,
    void Function() onPressed,
    String buttonText
    // double boxWidth, double boxHeight
    ) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(promptText),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(onPressed: onPressed, child: Text(buttonText))
      ],
    ),
  );
}
