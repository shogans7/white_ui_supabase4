import 'package:flutter/material.dart';

Widget pageLoadingView() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      SizedBox(height: 100),
      Center(
        child: CircularProgressIndicator(),
      ),
      SizedBox(height: 100),
    ],
  );
}
