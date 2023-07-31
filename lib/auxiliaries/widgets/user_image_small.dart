import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserImageSmall extends StatelessWidget {
  final String url;
  final double height;
  final double width;

  const UserImageSmall({
    Key? key,
    required this.url,
    this.height = 60,
    this.width = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              height: height,
              width: width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                color: Theme.of(context).primaryColor,
              ),
            ),
        placeholder: (context, url) => Container(
              margin: const EdgeInsets.only(top: 8, right: 8),
              height: height,
              width: width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                gradient: LinearGradient(
                  colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ));
  }
}
