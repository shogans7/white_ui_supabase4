import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/likes/likes_state.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';

class LikesBloc extends Bloc<LikesEvent, LikesState> {
  final AppViewBloc appViewBloc;
  final LikesRepository likesRepo;
  final CrewRepository crewRepo;
  final VenueRepository venueRepo;

  LikesBloc({
    required this.appViewBloc,
    required this.likesRepo,
    required this.crewRepo,
    required this.venueRepo,
    required Profile user,
  }) : super(LikesState(user: user)) {
    appViewBloc.stream.listen((appViewState) {
      if (isUserProfileUpdated(appViewState.user)) {
        add(AppViewUserUpdatedLikeEvent(user: appViewState.user));
        // emit(state.copyWith(user: appViewState.user));
      }
    });
    on<InitLikesEvent>(_mapInitLikesEvent);
    on<AppViewUserUpdatedLikeEvent>(_mapAppViewUserUpdatedLikeEvent);
    on<DirectRerouteEvent>(_mapDirectRerouteEvent);
    on<ResetRouteEvent>(_mapResetRouteEvent);
    on<LoadOlderLikes>(_mapLoadOlderLikes);
    on<LikesReloadEvent>(_mapLikesReloadEvent);
    on<LikesUserUpdatedEvent>(_mapLikesUserUpdatedEvent);
    on<ConfirmPendingMatchEvent>(_mapConfirmPendingMatchEvent);
  }

  _mapInitLikesEvent(InitLikesEvent event, Emitter<LikesState> emit) async {
    // NB: likes date is not a filter on first query, because recieved likes is fetched via crew which has date baked in
    var receivedLikes = state.user.crew?.receivedLikes;
    receivedLikes?.removeWhere((key, value) => value.currentMatch != null); // REMOVES LIKES OF THOSE ALREADY MATCHED WITH SOMEONE ELSE
    var pendingMatches = state.user.pendingMatchConfirmations;
    Match? confirmedMatch = state.user.currentMatch;
    emit(state.copyWith(receivedLikes: receivedLikes, pendingMatches: pendingMatches, confirmedMatch: confirmedMatch));
    emit(state.copyWith(loadingState: const Loaded()));
  }

  _mapAppViewUserUpdatedLikeEvent(AppViewUserUpdatedLikeEvent event, Emitter<LikesState> emit) {
    var receivedLikes = state.user.crew?.receivedLikes;
    // var pendingMatches = state.user.crew?.pendingMatchConfirmations;
    // TODO: how do we handle pendingMatches here? one is coming from crew, the other from user
    emit(state.copyWith(user: event.user, receivedLikes: receivedLikes));
  }

  // _mapPendingLikesEvent(PendingLikesEvent event, Emitter<LikesState> emit) async {
  //   // List<Crew>? pendingMatches = state.pendingMatches;
  //   pendingMatches?.add(event.listenerGroup);
  //   // List<Group>? pendingMatches = await likesRepo.getPendingMatches(state.user);
  //   emit(state.copyWith(pendingMatches: pendingMatches));
  // }

  _mapDirectRerouteEvent(DirectRerouteEvent event, Emitter<LikesState> emit) async {
    emit(state.copyWith(directReroute: true));
  }

  _mapResetRouteEvent(ResetRouteEvent event, Emitter<LikesState> emit) async {
    emit(state.copyWith(directReroute: false));
  }

  _mapLoadOlderLikes(LoadOlderLikes event, Emitter<LikesState> emit) async {
    String userId = state.user.id!;
    Map<dynamic, Like> olderReceivedLikes = await likesRepo.getOlderLikes(userId);

    emit(state.copyWith(olderReceivedLikes: olderReceivedLikes));
  }

  _mapLikesReloadEvent(LikesReloadEvent event, Emitter<LikesState> emit) async {
    Profile currentUser = state.user;
    String? crewId = currentUser.crew?.id;
    if (crewId != null) {
      emit(state.copyWith(loadingState: const Loading()));
      Crew? crew = await likesRepo.getUsersLikesAndPendingMatchesFromCrewId(crewId);
      if (crew != null) {
        currentUser.crew = crew; // Might break everything as doesnt have own crews users?
        appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
      }
      emit(state.copyWith(loadingState: const Loaded()));
    }
  }

  _mapLikesUserUpdatedEvent(LikesUserUpdatedEvent event, Emitter<LikesState> emit) {
    emit(state.copyWith(user: event.user));
  }

  _mapConfirmPendingMatchEvent(ConfirmPendingMatchEvent event, Emitter<LikesState> emit) async {
    Profile currentUser = state.user;
    MatchConfirmation? confirmedPendingMatch;
    confirmedPendingMatch = await likesRepo.confirmPendingMatch(event.pendingMatch);
    if (confirmedPendingMatch != null) {
      print("was that confirmed?");
      print(confirmedPendingMatch.confirmed);
      currentUser.pendingMatchConfirmations?[confirmedPendingMatch.otherCrewId] = confirmedPendingMatch;
      appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
    }
  }
}
