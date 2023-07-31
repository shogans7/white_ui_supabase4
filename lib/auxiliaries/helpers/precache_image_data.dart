import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

void precacheGroupsImageData(List<Crew>? crews, BuildContext context, Function() updateImagesLoadedState) async {
  debugPrint("called precahce imageurls");
  List<String> imageUrls = [];
  if (crews != null) {
    for (Crew crew in crews) {
      for (Profile user in crew.users!.values) {
        imageUrls.add(user.avatarUrl!);
      }
    }
    try {
      Future.wait(imageUrls.map((imageUrl) => cacheImage(context, imageUrl)));
      updateImagesLoadedState();
    } catch (e) {
      rethrow;
    }
  } else {
    debugPrint("crews null, calling setState");
    updateImagesLoadedState();
  }
  // precacheImage(CachedNetworkImageProvider(group.senderAvatarUrl!), context);
}

Future cacheImage(BuildContext context, String imageUrl) {
  return precacheImage(CachedNetworkImageProvider(imageUrl), context);
}
