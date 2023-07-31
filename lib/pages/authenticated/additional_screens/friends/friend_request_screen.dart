import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key, required this.friendsBloc}) : super(key: key);

  final FriendsBloc friendsBloc;

  @override
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  _FriendRequestScreenState() : super();

  @override
  Widget build(BuildContext context) {
    final friendsBloc = widget.friendsBloc;
    return BlocProvider.value(
        value: friendsBloc,
        child: BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              final formStatus = state.formStatus;
              if (formStatus is SubmissionSuccess) {
                showSnackBar(context, "Friend request sent");
                context.read<FriendsBloc>().add(FriendsResetFormStatus());
              }
              if (formStatus is SubmissionFailed) {
                showSnackBar(context, formStatus.exception.toString());
                context.read<FriendsBloc>().add(FriendsResetFormStatus());
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text("Friend Requests"),
                ),
                body: RefreshIndicator(
                    onRefresh: () async {
                      context.read<FriendsBloc>().add(FriendsReloadEvent());
                    },
                    child: GestureDetector(
                        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15,
                              ),
                              _friendRequests(),
                            ],
                          ),
                        ))))));
  }

  Widget _friendRequests() {
    return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
      final loadingState = state.loadingState;
      final receivedRequests = state.receivedFriendRequests;
      return loadingState is Loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : receivedRequests != null
              ? BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
                  final appViewBloc = context.read<FriendsBloc>().appViewBloc;
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.receivedFriendRequests?.length,
                      itemBuilder: (BuildContext context, int index) {
                        var request = state.receivedFriendRequests![index]!;
                        var userProfile = request.friend;
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
                                            userProfile: userProfile!,
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
                              leading: avatar(request.friend!.avatarUrl ?? ""),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                _confirmButton(requestId: request.id!, friend: request.friend!),
                                const SizedBox(width: 5),
                                _deleteButton(requestId: request.id!, friend: request.friend!)
                              ]),
                              title: Text(request.friend!.name ?? "")),
                        );
                      });
                })
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                );
    });
  }

  Widget _confirmButton({required String requestId, required Profile friend}) {
    return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
      return ElevatedButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(const BorderSide(width: 1)),
        ),
        onPressed: () {
          context.read<FriendsBloc>().add(ConfirmFriendRequest(requestId: requestId, friend: friend));
        },
        child: const Text("Confirm"),
      );
    });
  }

  Widget _deleteButton({required String requestId, required Profile friend}) {
    return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
      return TextButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(const BorderSide(width: 1, color: Colors.black)),
        ),
        onPressed: () {
          context.read<FriendsBloc>().add(DeleteFriendRequest(requestId: requestId, friend: friend));
        },
        child: const Text(
          "Delete",
        ),
      );
    });
  }
}
