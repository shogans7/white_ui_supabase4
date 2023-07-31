import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/button_dialog.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/generic_black_text_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/notifications_red_bubble.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/page_loading_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/friends/friend_request_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/friends/invite_contacts.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({Key? key}) : super(key: key);

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  final supabase = Supabase.instance.client;

  // @override
  // void initState() {
  //   final userId = supabase.auth.currentUser!.id;
  //   initListeners(userId);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AppViewBloc>()),
          BlocProvider.value(
            value: context.read<FriendsBloc>(),
          ),
        ],
        child: BlocListener<FriendsBloc, FriendsState>(listener: (context, state) {
          final formStatus = state.formStatus;
          if (formStatus is SubmissionSuccess) {
            showSnackBar(context, "Friend request sent");
            context.read<FriendsBloc>().add(FriendsResetFormStatus());
          }
          if (formStatus is SubmissionFailed) {
            showSnackBar(context, formStatus.exception.toString());
            context.read<FriendsBloc>().add(FriendsResetFormStatus());
          }
        }, child: BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
          int? notifications = state.receivedFriendRequests?.length;
          return Scaffold(
              appBar: AppBar(title: const Text("Add Friends"), actions: [
                Center(
                  child: Stack(children: [
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => FriendRequestScreen(friendsBloc: context.read<FriendsBloc>())));
                      },
                    ),
                    if (notifications != 0 && notifications != null) notificationsRedBubble(notifications),
                  ]),
                ),
              ]),
              backgroundColor: Colors.white,
              body: RefreshIndicator(
                  onRefresh: () async {
                    context.read<FriendsBloc>().add(FriendsReloadEvent());
                  },
                  child: GestureDetector(onTap: () => FocusScope.of(context).requestFocus(FocusNode()), child: _potentialFriends())));
        })));
  }

  Widget _potentialFriends() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
          final loadingState = state.loadingState;
          final contactsLength = state.buzzUsersInContacts?.length ?? 0;
          void onLoadSuggestionsButtonPressed() => context.read<FriendsBloc>().add(LoadMoreSuggestedFriends());
          void onInviteButtonPressed() => Navigator.push(context, MaterialPageRoute(builder: (_) => InviteContacts(friendsBloc: context.read<FriendsBloc>())));
          return loadingState is Loading
              ? pageLoadingView()
              : Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.75),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      friendListExpansionTile(state.potentialFriends!, "Suggestions (" + state.potentialFriends!.length.toString() + ")", "Load more suggestions", onLoadSuggestionsButtonPressed),
                      const SizedBox(
                        height: 10,
                      ),
                      friendListExpansionTile(state.buzzUsersInContacts ?? {}, "Contacts (" + contactsLength.toString() + ")", "Invite more contacts", onInviteButtonPressed,
                          emptyListReplacement: emptyContacts()),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
        }));
  }

  Widget friendListExpansionTile(Map<dynamic, Profile> friendList, String headingText, String buttonText, Function() onButtonPressed, {Widget? emptyListReplacement}) {
    return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
      final appViewBloc = context.read<AppViewBloc>();
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          maintainState: true,
          title: Text(
            headingText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          children: [
            if (friendList.isNotEmpty)
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: friendList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final userProfile = friendList.values.elementAt(index);
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
                          leading: avatar(userProfile.avatarUrl),
                          title: Text(
                            userProfile.name ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: orderFriendsForTile(friendsMap: userProfile.friends, currentUsersFriends: state.user.friends),
                          trailing: _addButton(userProfile),
                        ));
                  }),
            if (emptyListReplacement != null && friendList.isEmpty) emptyListReplacement,
            const SizedBox(
              height: 10,
            ),
            genericButton(buttonText, onButtonPressed),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    });
  }

  Widget emptyContacts() {
    return SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
              child: Container(
            decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Colors.black.withOpacity(0.1)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(7.0),
              child: Text(
                "None of your contacts seem to be using Buzz yet, invite some!",
                style: TextStyle(
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _addButton(Profile friend) {
    return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
      void addFriend() {
        context.read<FriendsBloc>().add(SendFriendRequest(user: state.user, friend: friend));
      }

      final loadingState = state.loadingState;
      final buttonContent = Text.rich(TextSpan(
          text: "Are you sure you want to add ",
          children: <TextSpan>[TextSpan(text: friend.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), const TextSpan(text: " as a friend?")]));
      return loadingState is Loading
          ? Container()
          : ElevatedButton(
              onPressed: () {
                showButtonDialog(context, "Add friend", buttonContent,
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                    ),
                    onConfirmed: addFriend);
              },
              child: const Icon(Icons.add),
            );
    });
  }

  void initListeners(String userId) async {
    supabase.channel('friend_requests').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'friend_requests', filter: 'receive_id=eq.$userId'),
      (payload, [ref]) {
        context.read<FriendsBloc>().add(FriendRequestListenerEvent(data: payload));
      },
    ).subscribe();
  }
}
