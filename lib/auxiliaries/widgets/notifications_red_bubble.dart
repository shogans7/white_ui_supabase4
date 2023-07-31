import 'package:flutter/material.dart';

Widget notificationsRedBubble(int notifications, {double? height, double? width, Alignment? alignment}) {
  return Container(
      width: width ?? 30,
      height: height ?? 30,
      alignment: alignment ?? Alignment.topRight,
      margin: const EdgeInsets.only(top: 5),
      child: Container(
        width: 15,
        height: 15,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Center(
            child: Text(
              notifications.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ));
}
