import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/match_posts.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/venue/venue_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';

class MatchListScreen extends StatefulWidget {
  final Map<dynamic, Match>? matchHistory;
  final String? heading;
  final Profile currentUser;
  final FriendsBloc friendsBloc;

  const MatchListScreen({Key? key, required this.currentUser, required this.matchHistory, this.heading, required this.friendsBloc}) : super(key: key);

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final FriendsBloc friendsBloc = widget.friendsBloc;
    final AppViewBloc appViewBloc = friendsBloc.appViewBloc;

    void onProfileTap(Profile userProfile) async {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (context) => ProfileViewBloc(
                        appViewBloc: appViewBloc,
                        likesRepo: context.read<LikesRepository>(),
                        currentUser: widget.currentUser,
                        userProfile: userProfile,
                      )..add(InitViewProfileEvent()),
                  child: ProfileView(
                    friendsBloc: friendsBloc,
                  ))));
    }

    void onVenueTap(Venue venue) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => BlocProvider(
                  create: (context) => VenueBloc(
                        currentUser: widget.currentUser,
                        venue: venue,
                        likesRepo: context.read<LikesRepository>(),
                        venueRepo: context.read<VenueRepository>(),
                      )..add(InitVenueEvent()),
                  child: VenueView(
                    friendsBloc: friendsBloc,
                  ))));
    }

    // widget.friends?.removeWhere((key, value) => key == widget.currentUser.id);
    // final friendsBloc = widget.friendsBloc;
    return
        // BlocProvider.value(
        //     value: friendsBloc,
        //     child:
        Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              title: widget.heading != null ? Text(widget.heading!) : null,
            ),
            body:
                // BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
                //   final appViewBloc = context.read<FriendsBloc>().appViewBloc;

                (widget.matchHistory != null && widget.matchHistory!.isNotEmpty)
                    ? Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                        const SizedBox(
                          height: 15,
                        ),
                        matchPosts(widget.matchHistory!, width, onProfileTap: onProfileTap, onVenueTap: onVenueTap)
                        // ListView.builder(
                        //     shrinkWrap: true,
                        //     itemCount: widget.matchHistory!.values.length,
                        //     itemBuilder: (BuildContext context, int index) {
                        //       Match match = widget.matchHistory!.values.elementAt(index);
                        //       return GestureDetector(
                        //         onTap: () {
                        //           print("Unimplemented, you dork");
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         settings: const RouteSettings(name: "/firstOfChain"),
                        //         builder: (_) => BlocProvider(
                        //               create: (context) => ProfileViewBloc(
                        //                 appViewBloc: appViewBloc,
                        //                 likesRepo: context.read<LikesRepository>(),
                        //                 currentUser: state.user,
                        //                 userProfile: userProfile,
                        //               )..add(InitViewProfileEvent()),
                        //               child: ProfileView(
                        //                 friendsBloc: context.read<FriendsBloc>(),
                        //               ),
                        //       //             )));
                        //     },
                        //     child: ListTile(
                        //         shape: const Border(
                        //           // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                        //           bottom: BorderSide(color: Colors.transparent, width: 10),
                        //         ),
                        //         title: Text("Something")
                        //         // leading: avatar(userProfile.avatarUrl ?? ""),
                        //         // trailing: Row(mainAxisSize: MainAxisSize.min, children: [_addButton(userProfile, context)]),
                        //         // title: Text(
                        //         //   userProfile.name ?? "",
                        //         //   style: const TextStyle(fontWeight: FontWeight.bold),
                        //         // )
                        //         ),
                        //   );
                        // })
                      ])
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                      ));
    // })));
  }

  // Widget _addButton(Profile userProfile, BuildContext context) {
  //   final userId = userProfile.id;
  //   final String firstName = userProfile.name!.split(" ").first;
  //   FriendshipState friendshipState = (widget.currentUser.friends != null && widget.currentUser.friends!.keys.contains(userId))
  //       ? FriendshipState.friends
  //       : (widget.currentUser.sentFriendRequests != null && widget.currentUser.sentFriendRequests!.keys.contains(userId))
  //           ? FriendshipState.sentRequest
  //           : (widget.currentUser.receivedFriendRequests != null && widget.currentUser.receivedFriendRequests!.keys.contains(userId))
  //               ? FriendshipState.receivedRequest
  //               : FriendshipState.none;
  //   // void onAddFriendPressed() => context.read<FriendsBloc>().add(SendFriendRequest(user: state.currentUser, friend: state.userProfile));
  //   final buttonContent = Text.rich(TextSpan(
  //       text: "Are you sure you want to add ",
  //       children: <TextSpan>[TextSpan(text: userProfile.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), const TextSpan(text: " as a friend?")]));
  //   return (friendshipState == FriendshipState.friends)
  //       ? TextButton(
  //           style: ButtonStyle(
  //             minimumSize: MaterialStateProperty.all(const Size(100, 35)),
  //             side: MaterialStateProperty.all(const BorderSide(width: 1)),
  //           ),
  //           onPressed: () {
  //             // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: receivedRequest.id!, friend: state.userProfile));
  //           },
  //           child: const Text(
  //             "Friends",
  //             style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
  //           ))
  //       : (friendshipState == FriendshipState.sentRequest)
  //           ? TextButton(
  //               style: ButtonStyle(
  //                 minimumSize: MaterialStateProperty.all(const Size(100, 35)),
  //                 // minimumSize: MaterialStateProperty.all(const Size(200, 10)),
  //                 side: MaterialStateProperty.all(const BorderSide(width: 1)),
  //                 backgroundColor: MaterialStateProperty.all(Colors.black),
  //               ),
  //               onPressed: () {
  //                 // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: state.friendRequest.id!, friend: state.userProfile));
  //               },
  //               child: const Text(
  //                 "Requested",
  //                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  //               ))
  //           : (friendshipState == FriendshipState.receivedRequest)
  //               ? ElevatedButton(
  //                   style: ButtonStyle(
  //                     elevation: MaterialStateProperty.all(5),
  //                     // minimumSize: MaterialStateProperty.all(const Size(200, 10)),
  //                     side: MaterialStateProperty.all(const BorderSide(width: 1)),
  //                     backgroundColor: MaterialStateProperty.all(Colors.white),
  //                     // backgroundColor: MaterialStateProperty.all(Colors.green[400]),
  //                   ),
  //                   child: Text.rich(
  //                     TextSpan(
  //                       text: "Accept ",
  //                       children: [
  //                         TextSpan(text: firstName + "'s", style: const TextStyle(fontWeight: FontWeight.bold)),
  //                         const TextSpan(text: " friend request"),
  //                       ],
  //                     ),
  //                     style: const TextStyle(color: Colors.green),
  //                   ),
  //                   onPressed: () {
  //                     // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: state.friendRequest!.id!, friend: state.userProfile));
  //                   },
  //                 )
  //               : TextButton(
  //                   style: ButtonStyle(
  //                     minimumSize: MaterialStateProperty.all(const Size(100, 35)),
  //                     // minimumSize: MaterialStateProperty.all(const Size(200, 10)),
  //                     side: MaterialStateProperty.all(const BorderSide(width: 1)),
  //                   ),
  //                   onPressed: () {
  //                     showButtonDialog(
  //                       context, "Add Friend", buttonContent,
  //                       icon: const Icon(
  //                         Icons.person_add,
  //                         color: Colors.black,
  //                       ),
  //                       // onConfirmed: onAddFriendPressed
  //                     );
  //                   },
  //                   child: const Text(
  //                     "Add Friend",
  //                     // style: TextStyle(fontWeight: FontWeight.bold),
  //                   ),
  //                 );
  // }
}
