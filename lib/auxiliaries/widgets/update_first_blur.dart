import 'dart:ui';

import 'package:flutter/material.dart';

Widget updateFirstBlur(BuildContext context, Widget Function() backgroundWidget, String promptText, Color promptColor, void Function() onPressed, double boxWidth, double boxHeight) {
  return Stack(children: [
    backgroundWidget(),
    Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.not_interested,
              size: 75,
              // color: Colors.wh,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Text(
                  promptText,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: promptColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextButton(
              onPressed: onPressed,
              // onPressed: onPressed,
              child: const Text(
                "Take me there",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                fixedSize: MaterialStateProperty.all(const Size(200, 50)),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(const BorderSide(width: 3, color: Colors.black)),
              ),
            )
            // GestureDetector(
            //   onTap: () {
            //     onPressed();
            //   },
            //   child:
            //   Container(
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(20),
            //         border: Border.all(color: Colors.black.withOpacity(0.75), width: 2),
            //       ),
            //       height: boxWidth / 3,
            //       width: boxWidth / 2,
            //       // color: Colors.white,
            //       child: Padding(
            //         padding: const EdgeInsets.all(15.0),
            //         child: Center(
            //             child: Text(
            //           textToUpdate,
            //           textAlign: TextAlign.center,
            //         )),
            //       )),
            // ),
          ],
        ),
      ),
    ),
  ]);
}
