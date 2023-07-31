import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget profilePicture(String? imageUrl, {Function? onPressed}) {
  return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.transparent,
        border: Border(
            bottom: BorderSide(
          width: 2,
          color: Colors.black,
        )),
        boxShadow: [BoxShadow(offset: Offset.zero, blurRadius: 0.0, spreadRadius: 0.0)],
      ),
      width: double.infinity,
      height: 300,
      child: ClipRRect(
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                  size: 50,
                ),
              )
            : IconButton(
                onPressed: (onPressed != null) ? () => onPressed : () {},
                icon: const Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                  size: 50,
                ),
              ),
      ));
}
