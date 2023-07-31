import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/intro_page_skeleton.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/video.dart';

class IntroPageTwo extends StatefulWidget {
  const IntroPageTwo({Key? key}) : super(key: key);

  @override
  State<IntroPageTwo> createState() => _IntroPageTwoState();
}

class _IntroPageTwoState extends State<IntroPageTwo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/videos/crew.mp4',
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
    return introPage(context, videoWidget(), "Get your crew and get ready to party!");
  }

  Widget videoWidget() {
    return video(_controller);
  }
}
