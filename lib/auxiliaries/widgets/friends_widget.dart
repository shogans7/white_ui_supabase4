import 'package:flutter/material.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/friend_avatar.dart';

Widget friendsWidget(Map<dynamic, Profile> friends, double width, Function onProfileTap, {Function? onFriendsTap}) {
  // var friends = user.friends;
  // var friendsIds = state.friends!.keys.toList();
  if (friends.isNotEmpty) {
    return Row(children: [
      Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1))),
        constraints: BoxConstraints(maxWidth: (width) - 2, maxHeight: 150),
        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
              stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: _friendsBox(friends, onProfileTap, onFriendsTap: onFriendsTap),
        ),
      ),
    ]);
  } else {
    return Container();
  }
  // });
}

Widget _friendsBox(Map<dynamic, Profile> friends, Function onProfileTap, {Function? onFriendsTap}) {
  // final appViewBloc = context.read<ProfileViewBloc>().appViewBloc;
  return ClipRRect(
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: (onFriendsTap != null) ? () => onFriendsTap(friends) : () {},
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(friends.length.toString()),
                ],
              ),
            ),
            const SizedBox(width: 10, height: 80),
            Flexible(
              fit: FlexFit.loose,
              child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
                      ),
                    );
                  },
                  physics: const AlwaysScrollableScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: friends.length,
                  itemBuilder: (BuildContext context, int index) {
                    Profile userProfile = friends.values.elementAt(index);
                    return ListTile(
                      onTap: () => onProfileTap(userProfile),
                      // onTap: () async {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (_) => BlocProvider(
                      //             create: (context) => ProfileViewBloc(
                      //                   appViewBloc: appViewBloc,
                      //                   likesRepo: context.read<LikesRepository>(),
                      //                   currentUser: state.currentUser,
                      //                   userProfile: userProfile,
                      //                 )..add(InitViewProfileEvent()),
                      //             child: ProfileView(
                      //               friendsBloc: context.read<FriendsBloc>(),
                      //             ))));
                      // },
                      trailing: friendAvatar(userProfile.avatarUrl),
                      title: Text(
                        userProfile.name!,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      // ),
                      // )
                    );
                  }),
            ),
          ])));
  // });
}
