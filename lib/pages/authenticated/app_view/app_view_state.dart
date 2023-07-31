import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

enum OnboardingState { contacts, profilePhoto, profileDetails, finished }

class AppViewState {
  final int? screenIndex;
  final Profile user; //contains friends, currentGroup, matches, pending matches, likes,
  final Crew? matchedCrew;
  // final Venue? matchedVenue;
  final bool? clearGroup;
  final bool? matched;
  final bool? refreshFriends;

  AppViewState({this.screenIndex, required this.user, this.matchedCrew, /*this.matchedVenue,*/ this.clearGroup, this.matched, this.refreshFriends});

  AppViewState copyWith({int? screenIndex, Profile? user, Crew? matchedCrew, /*Venue? matchedVenue,*/ bool clearGroup = false, bool? matched, bool? refreshFriends}) {
    return AppViewState(
      screenIndex: screenIndex ?? this.screenIndex,
      user: user ?? this.user,
      matchedCrew: clearGroup == true ? null : matchedCrew ?? this.matchedCrew,
      // matchedVenue: matchedVenue ?? this.matchedVenue,
      // clearGroup: clearGroup ?? this.clearGroup,
      // NEED a clause in bloc s.t. can handle overwriting a prev. group (current structure has group, and cleargroup working for one, but if we emit another group from the listener, clearGroup stays false)
      matched: matched ?? this.matched,
      refreshFriends: refreshFriends ?? this.refreshFriends,
    );
  }
}
