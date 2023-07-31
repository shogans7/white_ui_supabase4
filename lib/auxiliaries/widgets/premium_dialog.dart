import 'package:flutter/material.dart';

Future<void> showPremiumDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Row(children: const [
          Text(
            "Upgrade",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("That's a premium feature!"),
              SizedBox(
                height: 10,
              ),
              Text(
                "Upgrade to premium?",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text(
              'Upgrade',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              // TODO: implement upgrade to premium
              debugPrint("Take him to premium-ville!");
              // print("Confirmed");
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
