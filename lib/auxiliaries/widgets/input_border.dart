import 'package:flutter/material.dart';

border() {
  return const OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide(
      color: Color(0xffB3ABAB),
      width: 1.0,
    ),
  );
}
