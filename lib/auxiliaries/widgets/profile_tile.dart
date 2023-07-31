import 'package:flutter/material.dart';

Widget profileTile({required Icon leading, required Widget title}) {
  return Container(
      decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.1), width: 1)),
      child: ListTile(
        leading: leading,
        title: title,
      ));
}
