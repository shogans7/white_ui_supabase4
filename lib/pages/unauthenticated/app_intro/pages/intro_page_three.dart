import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/intro_page_skeleton.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/video.dart';

class IntroPageThree extends StatefulWidget {
  const IntroPageThree({Key? key}) : super(key: key);

  @override
  State<IntroPageThree> createState() => _IntroPageThreeState();
}

class _IntroPageThreeState extends State<IntroPageThree> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/swiping-crews.mov',
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
      "Send likes to crews you want to meet",
    );
  }

  Widget videoWidget() {
    return video(_controller);
  }
}
