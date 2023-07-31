import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class FriendsState {
  final Profile user;
  final LoadingState loadingState;
  final FormSubmissionStatus formStatus;
  final int loadMoreSuggestedFriendsIndex;
  final Map<dynamic, Profile>? potentialFriends;
  final List<FriendRequest?>? receivedFriendRequests;
  final Map<dynamic, Profile?>? friends;
  final Map<dynamic, Profile>? buzzUsersInContacts;
  final Map<dynamic, dynamic>? otherContacts;

  FriendsState(
      {required this.user,
      this.loadingState = const Loading(),
      this.formStatus = const InitialFormStatus(),
      this.loadMoreSuggestedFriendsIndex = 0,
      this.potentialFriends,
      this.receivedFriendRequests,
      this.friends,
      this.buzzUsersInContacts,
      this.otherContacts});

  FriendsState copyWith({
    Profile? user,
    LoadingState? loadingState,
    FormSubmissionStatus? formStatus,
    int? loadMoreSuggestedFriendsIndex,
    Map<dynamic, Profile>? potentialFriends,
    List<FriendRequest?>? receivedFriendRequests,
    Map<dynamic, Profile?>? friends,
    Map<dynamic, Profile>? buzzUsersInContacts,
    Map<dynamic, dynamic>? otherContacts,
  }) {
    return FriendsState(
      user: user ?? this.user,
      loadingState: loadingState ?? this.loadingState,
      formStatus: formStatus ?? this.formStatus,
      loadMoreSuggestedFriendsIndex: loadMoreSuggestedFriendsIndex ?? this.loadMoreSuggestedFriendsIndex,
      potentialFriends: potentialFriends ?? this.potentialFriends,
      receivedFriendRequests: receivedFriendRequests ?? this.receivedFriendRequests,
      friends: friends ?? this.friends,
      buzzUsersInContacts: buzzUsersInContacts ?? this.buzzUsersInContacts,
      otherContacts: otherContacts ?? this.otherContacts,
    );
  }
}
