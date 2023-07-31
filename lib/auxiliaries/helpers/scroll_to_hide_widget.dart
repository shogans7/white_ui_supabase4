import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollToHideWidget extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final Duration duration;

  const ScrollToHideWidget({Key? key, required this.child, required this.controller, this.duration = const Duration(milliseconds: 200)}) : super(key: key);

  @override
  _ScrollToHideWidgetState createState() => _ScrollToHideWidgetState();
}

class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
  bool isVisibile = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listen);
  }

  @override
  void dispose() {
    widget.controller.removeListener(listen);
    super.dispose();
  }

  void listen() {
    final direction = widget.controller.position.userScrollDirection;
    // final speed = widget.controller.position.
    if (direction == ScrollDirection.forward) {
      show();
    } else if (direction == ScrollDirection.reverse) {
      hide();
    }
  }

  void show() {
    if (!isVisibile) setState(() => isVisibile = true);
  }

  void hide() {
    if (isVisibile) setState(() => isVisibile = false);
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        height: isVisibile ? kBottomNavigationBarHeight * 1.6 : 0,
        duration: widget.duration,
        child: Wrap(children: [widget.child]),
      );
}
