import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';

class FeedState {
  final Profile user;
  Map<dynamic, Match>? todaysMatches;
  Map<dynamic, Match>? previousMatches;
  bool? userHasFriends;
  final LoadingState loadingState;

  FeedState({required this.user, this.loadingState = const Loading(), this.todaysMatches, this.previousMatches, this.userHasFriends});

  FeedState copyWith({
    Profile? user,
    Map<dynamic, Match>? todaysMatches,
    Map<dynamic, Match>? previousMatches,
    bool? userHasFriends,
    LoadingState? loadingState,
  }) {
    return FeedState(
      user: user ?? this.user,
      todaysMatches: todaysMatches ?? this.todaysMatches,
      previousMatches: previousMatches ?? this.previousMatches,
      userHasFriends: userHasFriends ?? this.userHasFriends,
      loadingState: loadingState ?? this.loadingState,
    );
  }
}
