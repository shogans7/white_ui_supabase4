import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/intro_page_skeleton.dart';

class IntroPageOne extends StatelessWidget {
  const IntroPageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return introPage(context, _image(), "Once per week, Buzz goes live");
  }

  Widget _image() {
    return Image.asset(
      'assets/images/buzz_notif.PNG',
      fit: BoxFit.cover,
    );
  }
}
