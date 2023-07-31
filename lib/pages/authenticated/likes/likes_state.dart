import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';

class LikesState {
  final Profile user;
  final LoadingState loadingState;
  final Match? confirmedMatch;
  // final Venue? confirmedVenue;
  // final Group? listenerGroup;
  final Map<dynamic, MatchConfirmation>? pendingMatches;
  final Map<dynamic, Profile?>? receivedLikes;
  final Map<dynamic, Like?>? olderReceivedLikes;
  // final List<Venue>? venues;
  final bool? directReroute;

  LikesState({required this.user, this.loadingState = const Loading(), this.confirmedMatch, this.pendingMatches, this.receivedLikes, this.olderReceivedLikes, this.directReroute});

  LikesState copyWith({
    Profile? user,
    LoadingState? loadingState,
    Match? confirmedMatch,
    Map<dynamic, MatchConfirmation>? pendingMatches,
    Map<dynamic, Profile?>? receivedLikes,
    Map<dynamic, Like?>? olderReceivedLikes,
    bool? directReroute,
  }) {
    return LikesState(
      user: user ?? this.user,
      loadingState: loadingState ?? this.loadingState,
      confirmedMatch: confirmedMatch ?? this.confirmedMatch,
      pendingMatches: pendingMatches ?? this.pendingMatches,
      receivedLikes: receivedLikes ?? this.receivedLikes,
      olderReceivedLikes: olderReceivedLikes ?? this.olderReceivedLikes,
      directReroute: directReroute ?? this.directReroute,
    );
  }
}
