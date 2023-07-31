import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

Widget video(VideoPlayerController controller) {
  return controller.value.isInitialized
      ? FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            height: controller.value.size.height,
            width: controller.value.size.width,
            child: VideoPlayer(controller),
          ))
      : Container();
}
