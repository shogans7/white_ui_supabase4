import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/intro_page_skeleton.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/video.dart';

class IntroPageFour extends StatefulWidget {
  const IntroPageFour({Key? key}) : super(key: key);

  @override
  State<IntroPageFour> createState() => _IntroPageFourState();
}

class _IntroPageFourState extends State<IntroPageFour> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/manny-bar.mp4',
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
      "When you get a match, confirm where you want to go",
    );
  }

  Widget videoWidget() {
    return video(_controller);
  }
}
