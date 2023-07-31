import 'package:flutter/material.dart';

Future<void> showButtonDialog(BuildContext context, String title, Text content, {Icon? icon, void Function()? onCancelled, void Function()? onConfirmed, Text? subContent}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Row(children: [
          if (icon != null) icon,
          if (icon != null) const SizedBox(width: 25),
          // const Icon(
          //   Icons.person_add,
          //   color: Colors.black,
          // ),
          // const SizedBox(width: 25),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ]),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: (subContent != null) ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              content,
              if (subContent != null)
                const SizedBox(
                  height: 10,
                ),
              if (subContent != null) subContent,
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              if (onCancelled != null) onCancelled();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text(
              'Confirm',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: () {
              if (onConfirmed != null) onConfirmed();
              // print("Confirmed");
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
