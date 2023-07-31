import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class FriendsEvent {}

class InitFriendsEvent extends FriendsEvent {}

class AppViewUserUpdatedFriendsEvent extends FriendsEvent {
  Profile user;

  AppViewUserUpdatedFriendsEvent({required this.user});
}

class FriendsResetFormStatus extends FriendsEvent {}

class FriendsReloadEvent extends FriendsEvent {}

class LoadMoreSuggestedFriends extends FriendsEvent {}

class FriendRequestListenerEvent extends FriendsEvent {
  Map<dynamic, dynamic> data;

  FriendRequestListenerEvent({required this.data});
}

class SendFriendRequest extends FriendsEvent {
  final Profile? user;
  final Profile friend;

  SendFriendRequest({this.user, required this.friend});
}

class ConfirmFriendRequest extends FriendsEvent {
  final String requestId;
  final Profile friend;

  ConfirmFriendRequest({required this.requestId, required this.friend});
}

class DeleteFriendRequest extends FriendsEvent {
  final String? requestId;
  final Profile friend;

  DeleteFriendRequest({required this.requestId, required this.friend});
}

class InviteContactToBuzz extends FriendsEvent {
  String name;
  String phoneNumber;

  InviteContactToBuzz({required this.name, required this.phoneNumber});
}
