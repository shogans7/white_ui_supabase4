import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';

enum FriendshipState { currentUser, friends, sentRequest, receivedRequest, none }

class ProfileViewState {
  final Profile currentUser;
  final Profile userProfile;
  final LoadingState loadingState;
  final LoadingState? additionalDataLoadingState;
  FriendshipState? friendshipState;
  FriendRequest? friendRequest;
  // bool? isCurrentUser;
  // bool? alreadyFriends;
  // FriendRequest? sentRequest;
  // FriendRequest? receivedRequest;
  List<Like>? sentLikesHistory;
  List<Match>? matchHistory;

  ProfileViewState({
    required this.currentUser,
    required this.userProfile,
    this.loadingState = const Loading(),
    this.additionalDataLoadingState = const Loading(),
    this.friendshipState,
    this.friendRequest,
    this.sentLikesHistory,
    this.matchHistory,
  });

  ProfileViewState copyWith({
    Profile? currentUser,
    Profile? userProfile,
    LoadingState? loadingState,
    LoadingState? additionalDataLoadingState,
    FriendshipState? friendshipState,
    FriendRequest? friendRequest,
    // bool? isCurrentUser,
    // bool? alreadyFriends,
    // FriendRequest? sentRequest,
    // FriendRequest? receivedRequest,
    List<Like>? sentLikesHistory,
    List<Match>? matchHistory,
  }) {
    return ProfileViewState(
      currentUser: currentUser ?? this.currentUser,
      userProfile: userProfile ?? this.userProfile,
      loadingState: loadingState ?? this.loadingState,
      additionalDataLoadingState: additionalDataLoadingState ?? this.additionalDataLoadingState,
      friendshipState: friendshipState ?? this.friendshipState,
      friendRequest: friendRequest ?? this.friendRequest,
      // isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      // alreadyFriends: alreadyFriends ?? this.alreadyFriends,
      // sentRequest: sentRequest ?? this.sentRequest,
      // receivedRequest: receivedRequest ?? this.receivedRequest,
      sentLikesHistory: sentLikesHistory ?? this.sentLikesHistory,
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }
}
