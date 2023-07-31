import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

void showImageSourceActionSheet(BuildContext context, ImagePicker picker, Function(XFile) onSuccess) {
  void _selectImageSource(ImageSource imageSource) async {
    debugPrint("Getting image");
    final pickedImage = await picker.pickImage(source: imageSource);
    debugPrint("Image picker actually completed");
    if (pickedImage == null) {
      debugPrint("picked image null, return");
      return;
    } else {
      debugPrint("We have an image");
      onSuccess(pickedImage);
      // setState(() {
      //   print(pickedImage.path);
      //   // String copy = pickedImage.path;
      //   // _pickedImagePath == copy;
      //   // print(_pickedImagePath);
      //   // print(copy);
      //   imageFile = File(pickedImage.path);
      //   imageXFile = pickedImage;
      //   print(imageFile != null);
      //   _photoSelected = true;
      // });
    }
  }

  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _selectImageSource(ImageSource.camera);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Gallery'),
            onPressed: () {
              Navigator.pop(context);
              _selectImageSource(ImageSource.gallery);
            },
          )
        ],
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(children: [
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Camera'),
          onTap: () {
            Navigator.pop(context);
            _selectImageSource(ImageSource.camera);
          },
        ),
        ListTile(
          leading: const Icon(Icons.photo_album),
          title: const Text('Gallery'),
          onTap: () {
            Navigator.pop(context);
            _selectImageSource(ImageSource.gallery);
          },
        ),
      ]),
    );
  }
}
