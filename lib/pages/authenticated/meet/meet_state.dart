import 'package:cached_network_image/cached_network_image.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue_selection.dart';

class MeetState {
  final Profile user;
  final String city;
  final DateTime? dropTime;
  final Crew? usersCrew;
  final LoadingState loadingState;
  final FormSubmissionStatus formStatus;
  final int loadMoreCrewsIndex;
  final Map<dynamic, CrewRequest?>? receivedCrewRequests;
  final Map<dynamic, CrewRequest?>? sentCrewRequests;
  final List<Crew>? crews;
  final Match? confirmedMatch;
  final List<Venue>? venues;
  final List<bool>? venueIsChecked;
  final VenueSelection? venueSelection;
  final List<CachedNetworkImageProvider>? imageProviders;
  final int index;
  bool pressed;
  bool like;

  MeetState({
    required this.user,
    required this.city,
    required this.dropTime,
    this.usersCrew,
    this.loadingState = const Loading(),
    this.formStatus = const InitialFormStatus(),
    this.loadMoreCrewsIndex = 0,
    this.receivedCrewRequests,
    this.sentCrewRequests,
    this.crews,
    this.confirmedMatch,
    this.venues,
    this.venueIsChecked,
    this.venueSelection,
    this.imageProviders,
    this.index = 0,
    this.pressed = false,
    this.like = false,
  });

  MeetState copyWith({
    Profile? user,
    String? city,
    DateTime? dropTime,
    Crew? usersCrew,
    LoadingState? loadingState,
    FormSubmissionStatus? formStatus,
    int? loadMoreCrewsIndex,
    Map<dynamic, CrewRequest?>? receivedCrewRequests,
    Map<dynamic, CrewRequest?>? sentCrewRequests,
    List<Crew>? crews,
    Match? confirmedMatch,
    List<Venue>? venues,
    List<bool>? venueIsChecked,
    VenueSelection? venueSelection,
    List<CachedNetworkImageProvider>? imageProviders,
    int? index,
    bool? pressed,
    bool? like,
  }) {
    return MeetState(
      user: user ?? this.user,
      city: city ?? this.city,
      dropTime: dropTime ?? this.dropTime,
      usersCrew: usersCrew ?? this.usersCrew,
      loadingState: loadingState ?? this.loadingState,
      formStatus: formStatus ?? this.formStatus,
      loadMoreCrewsIndex: loadMoreCrewsIndex ?? this.loadMoreCrewsIndex,
      receivedCrewRequests: receivedCrewRequests ?? this.receivedCrewRequests,
      sentCrewRequests: sentCrewRequests ?? this.sentCrewRequests,
      crews: crews ?? this.crews,
      confirmedMatch: confirmedMatch ?? this.confirmedMatch,
      venues: venues ?? this.venues,
      venueIsChecked: venueIsChecked ?? this.venueIsChecked,
      venueSelection: venueSelection ?? this.venueSelection,
      imageProviders: imageProviders,
      index: index ?? this.index,
      pressed: pressed ?? this.pressed,
      like: like ?? this.like,
    );
  }
}
