import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/feed/feed_event.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final AppViewBloc appViewBloc;
  final LikesRepository likesRepo;

  FeedBloc({
    required this.appViewBloc,
    required Profile user,
    required this.likesRepo,
  }) : super(FeedState(user: user)) {
    appViewBloc.stream.listen((appViewState) async {
      bool hasFriends = userHasFriends(appViewState.user);
      if (hasFriends) {
        add(FeedUserUpdatedEvent(hasFriends: hasFriends));
        // emit(state.copyWith(userHasFriends: hasFriends));
      }
    });
    on<InitFeedEvent>(_mapInitFeedEvent);
    on<FeedReloadEvent>(_mapFeedReloadEvent);
    on<FeedUserUpdatedEvent>(_mapFeedUserUpdatedEvent);
    on<LoadOlderPosts>(_mapLoadOlderPosts);
  }

  _mapInitFeedEvent(InitFeedEvent event, Emitter<FeedState> emit) async {
    bool hasFriends = userHasFriends(state.user);
    Map<dynamic, Match>? todaysMatches = await likesRepo.getTodaysMatches();
    emit(state.copyWith(userHasFriends: hasFriends, todaysMatches: todaysMatches, loadingState: const Loaded()));
  }

  _mapFeedReloadEvent(FeedReloadEvent event, Emitter<FeedState> emit) async {
    bool hasFriends = userHasFriends(state.user);
    emit(state.copyWith(loadingState: const Loading()));
    // List<MatchParent>? todaysMatches = await likesRepo.getMatches();
    emit(state.copyWith(userHasFriends: hasFriends));
    emit(state.copyWith(loadingState: const Loaded()));
  }

  _mapFeedUserUpdatedEvent(FeedUserUpdatedEvent event, Emitter<FeedState> emit) {
    emit(state.copyWith(userHasFriends: event.hasFriends));
  }

  _mapLoadOlderPosts(LoadOlderPosts event, Emitter<FeedState> emit) async {
    Map<dynamic, Match>? previousMatches = await likesRepo.getOlderMatches();
    emit(state.copyWith(previousMatches: previousMatches));
  }
}
