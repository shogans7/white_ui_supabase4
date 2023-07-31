import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/iphone_image_container.dart';

Widget introPage(BuildContext context, Widget imageChild, String text) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Container(alignment: Alignment.center, color: Colors.white, child: iphoneImageContainer(context, imageChild)),
      Positioned(
          bottom: 175.0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          )),
    ],
  );
}
