import 'package:flutter/material.dart';

Widget iphoneImageContainer(BuildContext context, Widget child) {
  final width = MediaQuery.of(context).size.width / 1.5;
  const iphoneAspectRatio = 19.5 / 9;
  return Stack(
    alignment: Alignment.topCenter,
    children: [
      Container(
        width: width,
        height: iphoneAspectRatio * width,
        foregroundDecoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color.fromARGB(0, 0, 0, 0), Colors.white], begin: Alignment.topCenter, end: Alignment(0.0, 0.35)),
          borderRadius: BorderRadius.circular(35),
          // border: Border.all(color: Colors.black.withOpacity(0.5), width: 2),
        ),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(35), child: child)),
      ),
      Positioned(
          top: 1.0,
          child: Container(
            width: width * 0.5,
            height: width * iphoneAspectRatio * 0.04,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(width * iphoneAspectRatio * 0.03), bottomRight: Radius.circular(width * iphoneAspectRatio * 0.03)),
              color: Colors.black,
            ),
          )),
    ],
  );
}
