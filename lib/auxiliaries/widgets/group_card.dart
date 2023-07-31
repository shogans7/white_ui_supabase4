import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/group_image_small.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/user_image_small.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({Key? key, required this.crew, this.onPressed, this.roundedTopCorners, this.onUserTap}) : super(key: key);

  final Crew crew;
  final Function? onPressed;
  final Function? onUserTap;
  final bool? roundedTopCorners;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  late bool groupPhotoShowing; //if initialised to false, will stay false
  BorderRadius? corners;

  Timer? timer;
  int index = 0;
  late int length;

  void initTimer() {
    if (timer != null && timer!.isActive) return;

    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          index = (index + 1) % length;
        });
      } else {
        throw Exception("Not mounted, fuckwit");
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    groupPhotoShowing = (widget.crew.groupPhotoUrl != null);
    length = widget.crew.users!.length;
    if (widget.roundedTopCorners != null && widget.roundedTopCorners!) {
      corners = const BorderRadius.all(Radius.circular(10));
    } else {
      corners = const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10));
    }
    if (!groupPhotoShowing) {
      initTimer();
    }
  }

  @override
  void didUpdateWidget(GroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.crew.id != oldWidget.crew.id) {
      setState(() {
        groupPhotoShowing = (widget.crew.groupPhotoUrl != null);
        length = widget.crew.users!.length;
        if (widget.roundedTopCorners != null && widget.roundedTopCorners!) {
          corners = const BorderRadius.all(Radius.circular(10));
        } else {
          corners = const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10));
        }
      });
      if (!groupPhotoShowing) {
        initTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Function? onPressed = widget.onPressed;
    Function? onUserTap = widget.onUserTap;
    Crew crew = widget.crew;
    List<String> urls = [];
    List<String> names = [];
    String? groupUrl = crew.groupPhotoUrl;
    crew.users!.forEach((key, value) {
      urls.add(value.avatarUrl!);
      names.add(value.name!);
    });

    return Hero(
      tag: 'group_card',
      child: Material(
          child: SizedBox(
        height: MediaQuery.of(context).size.height, // + appBarHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(children: [
          CachedNetworkImage(
            imageUrl: (groupPhotoShowing) ? groupUrl! : urls[index],
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                borderRadius: corners ?? const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 4,
                    blurRadius: 4,
                    offset: const Offset(3, 3),
                  )
                ],
              ),
            ),
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: corners ?? const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              gradient: const LinearGradient(
                colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Text(
              //   '${names[index][0].toUpperCase()}${names[index].substring(1)}',
              //   style: const TextStyle(
              //     color: Colors.white,
              //     fontSize: 30,
              //   ),
              // ),
              // const SizedBox(
              //   height: 5,
              // ),
              // Text(
              //   (notIndex().length == 1) ? "& " + names[notIndex()[0]] : names[notIndex()[0]] + " & " + names[notIndex()[1]],
              //   style: const TextStyle(color: Colors.white, fontSize: 20),
              // ),
              // const SizedBox(
              //   height: 5,
              // ),
              Row(children: [
                InkWell(
                    onTap: () {
                      setState(() {
                        index = 0;
                        groupPhotoShowing = false;
                      });
                      if (onPressed != null) {
                        onPressed(0);
                      }
                      if (onUserTap != null) {
                        onUserTap(0);
                      }
                    },
                    child: UserImageSmall(url: urls[0])),
                InkWell(
                    onTap: () {
                      setState(() {
                        index = 1;
                        groupPhotoShowing = false;
                      });
                      if (onPressed != null) {
                        onPressed(1);
                      }
                      if (onUserTap != null) {
                        onUserTap(1);
                      }
                    },
                    child: UserImageSmall(url: urls[1])),
                if (urls.length > 2)
                  InkWell(
                    onTap: () {
                      setState(() {
                        index = 2;
                        groupPhotoShowing = false;
                      });
                      if (onPressed != null) {
                        onPressed(2);
                      }
                      if (onUserTap != null) {
                        onUserTap(2);
                      }
                    },
                    child: UserImageSmall(url: urls[2]),
                  ),
                // InkWell(
                //   onTap: () => setState(() {
                //     index = 3;
                //   }),
                //   child: UserImageSmall(url: widget.urls![3] ?? 'https://picsum.photos/200'),
                // ),
                // InkWell(
                //   onTap: () => setState(() {
                //     index = 4;
                //   }),
                //   child: UserImageSmall(url: widget.urls![4] ?? 'https://picsum.photos/200'),
                // ),
                //       // Container(
                //       //   width: 35,
                //       //   height: 35,
                //       //   child: Icon(
                //       //     Icons.info_outline,
                //       //     size: 25,
                //       //     color: Theme.of(context).primaryColor,
                //       //   ),
                //       //   decoration: BoxDecoration(
                //       //     shape: BoxShape.circle,
                //       //     color: Colors.white,
                //       //   ),
                //       // ),
                //       // SizedBox(
                //       //   width: 100,
                //       // ),
              ]),
            ]),
          ),
          if (groupUrl != null && !groupPhotoShowing)
            Positioned(
                top: 10,
                right: 0,
                child: InkWell(
                    onTap: () => setState(() {
                          groupPhotoShowing = true;
                        }),
                    child: GroupImageSmall(url: groupUrl)))
        ]),
      )),
      // )
    );
  }
}
