import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';

class VenueState {
  final Profile currentUser;
  final Venue venue;
  final LoadingState loadingState;
  Map<dynamic, Match>? tonightsMatches;

  VenueState({required this.currentUser, required this.venue, this.loadingState = const Loading(), this.tonightsMatches});

  VenueState copyWith({
    Profile? currentUser,
    Venue? venue,
    LoadingState? loadingState,
    Map<dynamic, Match>? tonightsMatches,
  }) {
    return VenueState(
      currentUser: currentUser ?? this.currentUser,
      venue: venue ?? this.venue,
      loadingState: loadingState ?? this.loadingState,
      tonightsMatches: tonightsMatches ?? this.tonightsMatches,
    );
  }
}
