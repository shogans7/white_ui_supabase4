import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class CrewRequestState {
  final Profile user;
  final LoadingState loadingState;
  Crew? crew;
  Map<dynamic, Profile>? friends;
  Map<dynamic, CrewRequest>? sentCrewRequests;
  Map<dynamic, CrewRequest>? receivedCrewRequests;

  CrewRequestState({
    required this.user,
    this.loadingState = const Loading(),
    this.crew,
    this.friends,
    this.sentCrewRequests,
    this.receivedCrewRequests,
  });

  CrewRequestState copyWith(
      {Profile? user,
      LoadingState? loadingState,
      Crew? crew,
      Map<dynamic, Profile>? friends,
      Map<dynamic, CrewRequest>? sentCrewRequests,
      Map<dynamic, CrewRequest>? receivedCrewRequests,
      bool clearCrew = false}) {
    return CrewRequestState(
      user: user ?? this.user,
      loadingState: loadingState ?? this.loadingState,
      crew: clearCrew ? null : crew ?? this.crew,
      friends: friends ?? this.friends,
      sentCrewRequests: sentCrewRequests ?? this.sentCrewRequests,
      receivedCrewRequests: receivedCrewRequests ?? this.receivedCrewRequests,
    );
  }
}
