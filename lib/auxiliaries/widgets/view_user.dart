import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/friends_widget.dart';

Widget viewUserWidget(Profile user, double width, Function onProfileTap, {bool? border, Function? onFriendsTap, Function? onMatchHistoryTap}) {
  return Padding(
    padding: const EdgeInsets.only(/*horizontal: 30.0,*/ top: 15.0),
    child: Container(
      decoration: BoxDecoration(
        border: (border == null || border) ? Border.all(color: Colors.black.withOpacity(0.2) /*Colors.black.withOpacity(0.1)*/, width: 1) : null,
        borderRadius: BorderRadius.circular(5),
      ),
      constraints: BoxConstraints(maxWidth: width),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          _detailsRow(user, width),
          if (user.bio != null) _bioView(user, width),
          friendsWidget(user.friends ?? {}, width, onProfileTap, onFriendsTap: onFriendsTap),
          if (user.matchHistory != null && user.matchHistory!.isNotEmpty) userMatchHistory(user, width, onMatchHistoryTap: onMatchHistoryTap)
        ],
      ),
    ),
  );
}

Widget _detailsRow(Profile user, double width) {
  DateTime today = DateTime.now();
  num? age;
  if (user.birthday != null) {
    age = today.year - user.birthday!.year;
  }
  Map? _smallIcons = {};
  if (age != null) {
    _smallIcons[age.toString()] = const Icon(Icons.cake);
  }
  if (user.city != null) {
    _smallIcons[user.city] = const Icon(Icons.location_city);
  }
  if (user.homeTown != null) {
    _smallIcons[user.homeTown] = const Icon(Icons.home);
  }
  if (user.occupation != null) {
    _smallIcons[user.occupation] = const Icon(Icons.work);
  }
  if (user.university != null) {
    _smallIcons[user.university] = const Icon(Icons.school);
  }
  return Row(
    children: [
      SizedBox(
        width: width - 2,
        height: 50,
        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: ListView.separated(
              // itemBuilder: itemBuilder,
              separatorBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
                  ),
                );
              },
              itemCount: _smallIcons.length,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                String key = _smallIcons.keys.elementAt(index);
                Icon icon = _smallIcons[key];
                return _smallIconWidget(icon, Text(key));
              }),
        ),
      ),
      // ),
    ],
  );
}

Widget _smallIconWidget(Icon icon, Text data) {
  return ClipRRect(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, const SizedBox(width: 10), data],
      ),
    ),
  );
}

Widget _bioView(Profile user, double width) {
  // return BlocBuilder<ProfileViewBloc, ProfileViewState>(
  //   builder: (context, state) {
  return Row(
    children: [
      Container(
        width: width - 2,
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
        ),
        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: _bioBox(user),
        ),
      ),
      // ),
    ],
  );
  //   },
  // );
}

Widget _bioBox(Profile user) {
  // return BlocBuilder<ProfileViewBloc, ProfileViewState>(
  //   builder: (context, state) {
  return ClipRRect(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.comment),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.bio!,
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
  //   },
  // );
}

Widget userMatchHistory(Profile user, double width, {Function? onMatchHistoryTap}) {
  return GestureDetector(
    onTap: () {
      if (onMatchHistoryTap != null) onMatchHistoryTap(user.matchHistory);
    },
    child: Container(
        width: width - 2,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ListTile(
            leading: const Icon(
              Icons.celebration,
              color: Colors.black,
            ),
            title: userMatchHistoryToText(user.matchHistory!),
          ),
        )),
  );
}
