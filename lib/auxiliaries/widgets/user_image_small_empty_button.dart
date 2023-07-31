import 'package:flutter/material.dart';

class UserImageSmallEmptyButton extends StatelessWidget {
  final Function? onPressed;
  final double height;
  final double width;

  const UserImageSmallEmptyButton({
    Key? key,
    required this.onPressed,
    this.height = 60,
    this.width = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, right: 8),
      height: height,
      width: width,
      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(8.0)), color: Colors.white54, border: Border.all(color: Colors.black.withOpacity(0.5), width: 1)),
      // gradient: LinearGradient(
      //   colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
      //   begin: Alignment.bottomCenter,
      //   end: Alignment.topCenter,
      // ),
      // ),
      child: Center(
        child: Icon(
          Icons.person,
          size: height,
        ),
      ),
    );
  }
}
