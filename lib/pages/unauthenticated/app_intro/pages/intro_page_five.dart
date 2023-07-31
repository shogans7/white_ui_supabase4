import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/intro_page_skeleton.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/video.dart';

class IntroPageFive extends StatefulWidget {
  const IntroPageFive({Key? key}) : super(key: key);

  @override
  State<IntroPageFive> createState() => _IntroPageFiveState();
}

class _IntroPageFiveState extends State<IntroPageFive> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/bar.mov',
    )..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return introPage(
      context,
      videoWidget(),
      "See where your friends are going, and who they're with",
    );
  }

  Widget videoWidget() {
    return video(_controller);
  }
}
