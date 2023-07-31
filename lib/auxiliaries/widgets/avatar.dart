import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget avatar(String? imageUrl) {
  return Container(
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.transparent,
    ),
    width: 50,
    height: 50,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(25),
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
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )
          : const Icon(
              Icons.person,
              color: Colors.white,
              size: 50,
            ),
    ),
  );
}
