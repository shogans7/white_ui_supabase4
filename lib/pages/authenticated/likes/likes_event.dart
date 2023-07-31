import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class LikesEvent {}

class InitLikesEvent extends LikesEvent {}

class AppViewUserUpdatedLikeEvent extends LikesEvent {
  Profile user;

  AppViewUserUpdatedLikeEvent({required this.user});
}

// class PendingLikesEvent extends LikesEvent {
//   Crew pendingCrew;

//   PendingLikesEvent({required this.listenerGroup});
// }

class DirectRerouteEvent extends LikesEvent {}

class ResetRouteEvent extends LikesEvent {}

class LoadOlderLikes extends LikesEvent {}

// class MatchMatchListenerEvent extends LikesEvent {
//   Group? group;
//   Venue? venue;

//   MatchMatchListenerEvent({required this.group, required this.venue});
// }

class LikesReloadEvent extends LikesEvent {}

class LikesUserUpdatedEvent extends LikesEvent {
  final Profile user;

  LikesUserUpdatedEvent({required this.user});
}

class ConfirmPendingMatchEvent extends LikesEvent {
  MatchConfirmation pendingMatch;

  ConfirmPendingMatchEvent({required this.pendingMatch});
}
