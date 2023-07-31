import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class AppViewEvent {}

class InitAppEvent extends AppViewEvent {}

class PendingMatchListenerEvent extends AppViewEvent {
  Map<dynamic, dynamic> data;

  PendingMatchListenerEvent({required this.data});
}

// class MatchListenerEvent extends AppViewEvent {
//   Map<dynamic, dynamic> data;
//   String? ownGroupId;

//   MatchListenerEvent({required this.data, required this.ownGroupId});
// }

class FriendshipListenerEvent extends AppViewEvent {
  Map<dynamic, dynamic> data;

  FriendshipListenerEvent({required this.data});
}

class CrewListenerEvent extends AppViewEvent {
  Map<dynamic, dynamic> data;

  CrewListenerEvent({required this.data});
}

class AppViewUserUpdatedEvent extends AppViewEvent {
  Profile user;
  bool? includesFriendData;

  AppViewUserUpdatedEvent({required this.user, this.includesFriendData});
}

class UpdateIndexEvent extends AppViewEvent {
  int? index;

  UpdateIndexEvent({required this.index});
}

class ClearGroup extends AppViewEvent {}

class RefreshFriendsEvent extends AppViewEvent {}
