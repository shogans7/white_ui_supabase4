import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/button_dialog.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_state.dart';

class FriendListScreen extends StatefulWidget {
  final Map<dynamic, Profile>? friends;
  final String? heading;
  final Profile currentUser;
  final FriendsBloc friendsBloc;

  const FriendListScreen({Key? key, required this.currentUser, required this.friends, this.heading, required this.friendsBloc}) : super(key: key);

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  @override
  Widget build(BuildContext context) {
    widget.friends?.removeWhere((key, value) => key == widget.currentUser.id);
    final friendsBloc = widget.friendsBloc;
    return BlocProvider.value(
        value: friendsBloc,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              title: widget.heading != null ? Text(widget.heading!) : null,
            ),
            body: BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
              final appViewBloc = context.read<FriendsBloc>().appViewBloc;

              return (widget.friends != null && widget.friends!.isNotEmpty)
                  ? Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                      const SizedBox(
                        height: 15,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.friends!.values.length,
                          itemBuilder: (BuildContext context, int index) {
                            Profile userProfile = widget.friends!.values.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        settings: const RouteSettings(name: "/firstOfChain"),
                                        builder: (_) => BlocProvider(
                                              create: (context) => ProfileViewBloc(
                                                appViewBloc: appViewBloc,
                                                likesRepo: context.read<LikesRepository>(),
                                                currentUser: state.user,
                                                userProfile: userProfile,
                                              )..add(InitViewProfileEvent()),
                                              child: ProfileView(
                                                friendsBloc: context.read<FriendsBloc>(),
                                              ),
                                            )));
                              },
                              child: ListTile(
                                  shape: const Border(
                                    // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                                    bottom: BorderSide(color: Colors.transparent, width: 10),
                                  ),
                                  leading: avatar(userProfile.avatarUrl ?? ""),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [_addButton(userProfile, context)]),
                                  title: Text(
                                    userProfile.name ?? "",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  )),
                            );
                          })
                    ])
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                    );
            })));
  }

  Widget _addButton(Profile userProfile, BuildContext context) {
    // return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
    final userId = userProfile.id;
    // final String firstName = userProfile.name!.split(" ").first;
    FriendshipState friendshipState = (widget.currentUser.friends != null && widget.currentUser.friends!.keys.contains(userId))
        ? FriendshipState.friends
        : (widget.currentUser.sentFriendRequests != null && widget.currentUser.sentFriendRequests!.keys.contains(userId))
            ? FriendshipState.sentRequest
            : (widget.currentUser.receivedFriendRequests != null && widget.currentUser.receivedFriendRequests!.keys.contains(userId))
                ? FriendshipState.receivedRequest
                : FriendshipState.none;
    void onAddFriendPressed() => context.read<FriendsBloc>().add(SendFriendRequest(user: widget.currentUser, friend: userProfile));
    final buttonContent = Text.rich(TextSpan(
        text: "Are you sure you want to add ",
        children: <TextSpan>[TextSpan(text: userProfile.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), const TextSpan(text: " as a friend?")]));
    return (friendshipState == FriendshipState.friends)
        ? TextButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(100, 35)),
              side: MaterialStateProperty.all(const BorderSide(width: 1)),
            ),
            onPressed: () {
              // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: receivedRequest.id!, friend: state.userProfile));
            },
            child: const Text(
              "Friends",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ))
        : (friendshipState == FriendshipState.sentRequest)
            ? TextButton(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(const Size(100, 35)),
                  // minimumSize: MaterialStateProperty.all(const Size(200, 10)),
                  side: MaterialStateProperty.all(const BorderSide(width: 1)),
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: state.friendRequest.id!, friend: state.userProfile));
                },
                child: const Text(
                  "Requested",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ))
            : (friendshipState == FriendshipState.receivedRequest)
                ? ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                      // minimumSize: MaterialStateProperty.all(const Size(200, 10)),
                      side: MaterialStateProperty.all(const BorderSide(width: 1)),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      // backgroundColor: MaterialStateProperty.all(Colors.green[400]),
                    ),
                    child: const Text(
                      "Accept Request",
                      // Text.rich(
                      //   TextSpan(
                      //     text: "Accept ",
                      //     children: [
                      //       TextSpan(text: firstName + "'s", style: const TextStyle(fontWeight: FontWeight.bold)),
                      //       const TextSpan(text: " friend request"),
                      //     ],
                      //   ),
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      var friendRequest = widget.currentUser.receivedFriendRequests![userProfile.id];
                      context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: friendRequest!.id!, friend: userProfile));

                      // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: state.friendRequest!.id!, friend: state.userProfile));
                    },
                  )
                : TextButton(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(const Size(100, 35)),
                      // minimumSize: MaterialStateProperty.all(const Size(200, 10)),
                      side: MaterialStateProperty.all(const BorderSide(width: 1)),
                    ),
                    onPressed: () {
                      showButtonDialog(context, "Add Friend", buttonContent,
                          icon: const Icon(
                            Icons.person_add,
                            color: Colors.black,
                          ),
                          onConfirmed: onAddFriendPressed);
                    },
                    child: const Text(
                      "Add Friend",
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
  }
}
