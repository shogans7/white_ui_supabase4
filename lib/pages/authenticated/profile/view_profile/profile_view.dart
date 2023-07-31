import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/button_dialog.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/friend_avatar.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/profile_picture.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/view_user.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/friends/friend_list_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/match_list_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_state.dart';

class ProfileView extends StatefulWidget {
  final FriendsBloc? friendsBloc;

  const ProfileView({Key? key, this.friendsBloc}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  List<String> cities = [
    "Dublin",
    "Cork",
    "Galway",
    "London",
    "Melbourne",
    "Sydney",
  ];

  List<String> genders = ["Male", "Female", "Other"];
  List<String> interstedInList = ["Men", "Women", "Everyone"];

  @override
  Widget build(BuildContext context) {
    final friendsBloc = widget.friendsBloc;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ProfileViewBloc>()),
        if (friendsBloc != null) BlocProvider.value(value: friendsBloc),
      ],
      child: BlocListener<ProfileViewBloc, ProfileViewState>(
        listener: (context, state) {},
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: _appBar(),
            body: BlocBuilder<ProfileViewBloc, ProfileViewState>(builder: (context, state) {
              return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProfileViewBloc>().add(ProfileReloadEvent());
                  },
                  child: GestureDetector(onTap: () => FocusScope.of(context).requestFocus(FocusNode()), child: _profilePage()));
            })),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    final appBarHeight = AppBar().preferredSize.height;
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: BlocBuilder<ProfileViewBloc, ProfileViewState>(builder: (context, state) {
        return AppBar(
          title: Text(state.userProfile.name!),
          backgroundColor: Colors.black87,
          // actions: [
          //   IconButton(
          //       icon: const Icon(Icons.clear),
          //       onPressed: () async {
          //         await Future.delayed(const Duration(milliseconds: 800));
          //         Navigator.of(context).popUntil(ModalRoute.withName("/firstOfChain"));
          //         Navigator.pop(context);
          //       }),
          // ],
        );
      }),
    );
  }

  Widget _profilePage() {
    return SingleChildScrollView(child: BlocBuilder<ProfileViewBloc, ProfileViewState>(builder: (context, state) {
      final loadingState = state.loadingState;
      final user = state.userProfile;
      final currentUser = state.currentUser;
      double width = MediaQuery.of(context).size.width * 0.95;
      final appViewBloc = context.read<ProfileViewBloc>().appViewBloc;
      void onProfileTap(Profile userProfile) async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => BlocProvider(
                    create: (context) => ProfileViewBloc(
                          appViewBloc: appViewBloc,
                          likesRepo: context.read<LikesRepository>(),
                          currentUser: state.currentUser,
                          userProfile: userProfile,
                        )..add(InitViewProfileEvent()),
                    child: ProfileView(
                      friendsBloc: context.read<FriendsBloc>(),
                    ))));
      }

      void onFriendsTap(Map<dynamic, Profile> friends) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FriendListScreen(
                      friendsBloc: context.read<FriendsBloc>(),
                      friends: friends,
                      heading: user.name! + "'s friends",
                      currentUser: currentUser,
                      // friendsBloc: context.read<FriendsBloc>(),
                    )));
      }

      void onMatchHistoryTap(Map<dynamic, Match> previousMatchesTogether) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MatchListScreen(
                      matchHistory: previousMatchesTogether,
                      // friendsBloc: context.read<FriendsBloc>(),
                      // friends: friends,
                      heading: user.name! + "'s matches",
                      currentUser: currentUser,
                      friendsBloc: context.read<FriendsBloc>(),
                    )));
      }

      return loadingState is Loading
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 10),
                Center(
                  child: CircularProgressIndicator(),
                ),
                SizedBox(height: 100),
              ],
            )
          : SafeArea(
              child: SizedBox(
              height: MediaQuery.of(context).size.height + 50, // - (AppBar().preferredSize.height + MediaQuery.of(context).viewPadding.top),
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Column(
                      children: [
                        profilePicture(user.avatarUrl),
                        _addButton(),
                        viewUserWidget(user, width, onProfileTap, onFriendsTap: onFriendsTap, onMatchHistoryTap: onMatchHistoryTap),
                        const SizedBox(
                          height: 20,
                        ),
                        if (state.userProfile.crew != null) _crew(),
                      ],
                    ),
                  ],
                ),
              ),
            ));
    }));
  }

  Widget _crew() {
    return BlocBuilder<ProfileViewBloc, ProfileViewState>(builder: (context, state) {
      final crew = state.userProfile.crew;
      Map<dynamic, Profile>? crewUsers = crew?.users!;
      crewUsers?.removeWhere((key, value) => key == state.userProfile.id);
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black.withOpacity(0.2) /*Colors.black.withOpacity(0.1)*/, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width * 0.95)),
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
                itemCount: crewUsers!.length,
                itemBuilder: (BuildContext context, int index) {
                  Profile userProfile = crewUsers.values.elementAt(index);
                  return ListTile(
                    onTap: () async {},
                    trailing: friendAvatar(userProfile.avatarUrl),
                    title: Text(
                      userProfile.name!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
          ));
    });
  }

  Widget _addButton() {
    return BlocBuilder<ProfileViewBloc, ProfileViewState>(builder: (context, state) {
      final userProfile = state.userProfile;
      final friendshipState = state.friendshipState;
      final String firstName = userProfile.name!.split(" ").first;
      void onAddFriendPressed() => context.read<FriendsBloc>().add(SendFriendRequest(user: state.currentUser, friend: state.userProfile));
      final buttonContent = Text.rich(TextSpan(
          text: "Are you sure you want to add ",
          children: <TextSpan>[TextSpan(text: userProfile.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), const TextSpan(text: " as a friend?")]));
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          (friendshipState == FriendshipState.currentUser)
              ? TextButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(200, 10)),
                    side: MaterialStateProperty.all(const BorderSide(width: 1)),
                  ),
                  onPressed: () {
                    // context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: receivedRequest.id!, friend: state.userProfile));
                  },
                  child: const Text(
                    "It's you!",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ))
              : (friendshipState == FriendshipState.friends)
                  ? TextButton(
                      style: ButtonStyle(
                        minimumSize: MaterialStateProperty.all(const Size(200, 10)),
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
                            minimumSize: MaterialStateProperty.all(const Size(200, 10)),
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
                              child: Text.rich(
                                TextSpan(
                                  text: "Accept ",
                                  children: [
                                    TextSpan(text: firstName + "'s", style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const TextSpan(text: " friend request"),
                                  ],
                                ),
                                style: const TextStyle(color: Colors.green),
                              ),
                              onPressed: () {
                                context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: state.friendRequest!.id!, friend: state.userProfile));
                              },
                            )
                          : TextButton(
                              style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all(const Size(200, 10)),
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
                            ),
        ],
      );
    });
  }
}
