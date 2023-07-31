import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue_selection.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/droptime_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_state.dart';

class MeetBloc extends Bloc<MeetEvent, MeetState> {
  final AppViewBloc appViewBloc;
  final FriendsRepository friendsRepo;
  final StorageRepository storageRepo;
  final CrewRepository crewRepo;
  final LikesRepository likesRepo;
  final DroptimeRepository dropRepo;
  final VenueRepository venueRepo;

  MeetBloc({
    required this.appViewBloc,
    required this.friendsRepo,
    required this.storageRepo,
    required this.crewRepo,
    required this.likesRepo,
    required this.dropRepo,
    required this.venueRepo,
    required Profile user,
    required DateTime? dropTime,
  }) : super(MeetState(user: user, dropTime: dropTime, city: user.city!)) {
    appViewBloc.stream.listen((appViewState) {
      if (isUserProfileUpdated(appViewState.user)) {
        add(AppViewUserUpdatedMeetEvent(user: appViewState.user));
      }
    });
    on<InitMeetEvent>(_mapInitMeetEvent);
    on<AppViewUserUpdatedMeetEvent>(_mapAppViewUserUpdatedMeetEvent);
    on<LoadMoreCrewsEvent>(_mapLoadMoreCrewsEvent);
    on<RefreshCrewsAlreadySwipedEvent>(_mapRefreshCrewsAlreadySwipedEvent);
    on<SendLikeEvent>(_mapSendLikeEvent);
    on<CrewRequestListenerEvent>(_mapCrewRequestListenerEvent);
    // on<MatchListenerEvent>(_mapMatchListenerEvent);
    on<ResetFormStatus>(_mapResetFormStatus);
    on<ChangeIndex>(_mapChangeIndex);
    on<ButtonPressed>(_mapButtonPressed);
    on<UpdateSelectedVenues>(_mapUpdateSelectedVenues);
  }

  _mapInitMeetEvent(InitMeetEvent event, Emitter<MeetState> emit) async {
    List<Crew> initialCrews = event.initialCrews;
    Crew? crew = state.user.crew;
    Match? confirmedMatch = state.user.currentMatch;
    VenueSelection? venueSelection;
    List<Venue>? venues = await venueRepo.getVenues(state.city);
    List<bool> venueIsChecked = List.generate(venues!.length, (index) => false);

    if (confirmedMatch != null) {
      venueSelection = await venueRepo.getVenueSelection(state.user.id!, confirmedMatch.id!);
      if (venueSelection!.selectedVenues != null) {
        for (var venueId in venueSelection.selectedVenues!) {
          int index = venues.indexWhere((venue) => venue.id == venueId);
          venueIsChecked[index] = true;
        }
      }
    }

    List<dynamic>? sentLikesIds = state.user.sentLikes?.keys.toList();
    if (sentLikesIds != null && sentLikesIds.isNotEmpty) {
      initialCrews.removeWhere((element) => sentLikesIds.contains(element.id));
    }

//NB: I include venue selection in the state, as it gives us the id to upsert with
//  it is possible an upsert could be done on user and match id
    emit(state.copyWith(
        usersCrew: crew,
        crews: initialCrews,
        confirmedMatch: confirmedMatch,
        venues: venues,
        venueIsChecked: venueIsChecked,
        venueSelection: venueSelection,
        loadMoreCrewsIndex: initialCrews.length,
        loadingState: const Loaded()));
  }

  _mapAppViewUserUpdatedMeetEvent(AppViewUserUpdatedMeetEvent event, Emitter<MeetState> emit) {
    // not redoing sent likes here as its uneccessary, but emitting the user with new sentLikes important for when hit refresh button
    emit(state.copyWith(user: event.user));
  }

  _mapLoadMoreCrewsEvent(LoadMoreCrewsEvent event, Emitter<MeetState> emit) async {
    debugPrint("...fetching more Crews from the db");
    int rangeStart = state.loadMoreCrewsIndex;
    int rangeEnd = state.loadMoreCrewsIndex + 2;

    List<Crew>? crews = state.crews;
    List<Crew>? moreCrews = await crewRepo.getCrews(state.user, rangeStart, rangeEnd);
    List<dynamic>? sentLikesIds = state.user.sentLikes?.keys.toList();
    if (sentLikesIds != null && sentLikesIds.isNotEmpty) {
      moreCrews?.removeWhere((element) => sentLikesIds.contains(element.id));
    }
    if (moreCrews != null) {
      crews?.addAll(moreCrews);
      emit(state.copyWith(crews: crews, loadMoreCrewsIndex: rangeStart + moreCrews.length));
    }
  }

  _mapRefreshCrewsAlreadySwipedEvent(RefreshCrewsAlreadySwipedEvent event, Emitter<MeetState> emit) async {
    debugPrint("...refreshing swiped Crews from the db");
    int rangeStart = 0;
    int rangeEnd = 100; // ??

    List<Crew>? crews = state.crews;
    List<Crew>? moreCrews = await crewRepo.getCrews(state.user, rangeStart, rangeEnd);
    List<dynamic>? sentLikesIds = state.user.sentLikes?.keys.toList();
    sentLikesIds?.retainWhere((element) => state.user.sentLikes![element]!.like == true); // keep the ids of crews user swiped right; we don't want to display these again
    if (sentLikesIds != null && sentLikesIds.isNotEmpty) {
      moreCrews?.removeWhere((element) => sentLikesIds.contains(element.id));
    }
    if (moreCrews != null) {
      crews?.addAll(moreCrews);
      emit(state.copyWith(crews: crews, loadMoreCrewsIndex: rangeEnd));
    }
  }

  _mapSendLikeEvent(SendLikeEvent event, Emitter<MeetState> emit) async {
    Profile currentUser = state.user;
    String userId = event.user!.id!;
    Crew ownCrew = event.currentCrew!;
    Crew otherCrew = event.otherCrew!;
    Like? sentLike = await likesRepo.sendLike(userId, ownCrew, otherCrew, event.like!);
    if (sentLike != null) {
      Map<dynamic, Like> updates = {otherCrew.id: sentLike};
      (currentUser.sentFriendRequests != null) ? currentUser.sentLikes?.addAll(updates) : currentUser.sentLikes = updates;
    }
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
    emit(state.copyWith(pressed: true, like: event.like));
    // List<Crew>? crews = state.crews;
    // if (crews != null) {
    //   if (crews.length < 10) {
    //     add(LoadMoreCrewsEvent());
    //   }
    // }
  }

  _mapCrewRequestListenerEvent(CrewRequestListenerEvent event, Emitter<MeetState> emit) async {
    Profile currentUser = state.user;
    CrewRequest crewRequest = CrewRequest.fromJson(event.data['new']);
    if (currentUser.id == crewRequest.receiverId) {
      if (crewRequest.status == 'request') {
        List<dynamic> existingRequestIds = currentUser.receivedCrewRequests?.keys.toList() ?? [];
        if (!existingRequestIds.contains(crewRequest.senderId)) {
          Profile? crewRequestSender = await getUserById(crewRequest.senderId!);
          crewRequest.friend = crewRequestSender;
          Map<dynamic, CrewRequest> updates = {crewRequest.senderId: crewRequest};
          (currentUser.receivedCrewRequests != null) ? currentUser.receivedCrewRequests?.addAll(updates) : currentUser.receivedCrewRequests = updates;
        }
      }
    }
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  // _mapMatchListenerEvent(MatchListenerEvent event, Emitter<MeetState> emit) async {
  //   Profile currentUser = state.user;
  //   CrewRequest crewRequest = CrewRequest.fromJson(event.data['new']);
  //   if (currentUser.id == crewRequest.receiverId) {
  //     if (crewRequest.status == 'request') {
  //       List<dynamic> existingRequestIds = currentUser.receivedCrewRequests?.keys.toList() ?? [];
  //       if (!existingRequestIds.contains(crewRequest.senderId)) {
  //         Profile? crewRequestSender = await getUserById(crewRequest.senderId!);
  //         crewRequest.friend = crewRequestSender;
  //         Map<dynamic, CrewRequest> updates = {crewRequest.senderId: crewRequest};
  //         (currentUser.receivedCrewRequests != null) ? currentUser.receivedCrewRequests?.addAll(updates) : currentUser.receivedCrewRequests = updates;
  //       }
  //     }
  //   }
  //   appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  // }

  _mapResetFormStatus(ResetFormStatus event, Emitter<MeetState> emit) {
    emit(state.copyWith(formStatus: const InitialFormStatus()));
  }

  _mapChangeIndex(ChangeIndex event, Emitter<MeetState> emit) {
    emit(state.copyWith(index: event.index));
  }

  _mapButtonPressed(ButtonPressed event, Emitter<MeetState> emit) {
    emit(state.copyWith(pressed: event.pressed));
  }

  _mapUpdateSelectedVenues(UpdateSelectedVenues event, Emitter<MeetState> emit) async {
    List<dynamic> selectedVenues = [];
    int index = 0;
    for (var isChecked in state.venueIsChecked!) {
      if (isChecked) {
        selectedVenues.add(state.venues![index].id);
      }
      index++;
    }
    await venueRepo.updateSelectedVenues(state.venueSelection!.id!, selectedVenues);
  }
}
