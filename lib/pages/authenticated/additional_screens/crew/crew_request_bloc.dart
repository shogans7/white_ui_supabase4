import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_state.dart';

class CrewRequestBloc extends Bloc<CrewRequestEvent, CrewRequestState> {
  final AppViewBloc appViewBloc;
  final CrewRepository crewRepo;

  CrewRequestBloc({
    required this.appViewBloc,
    required this.crewRepo,
    required Profile user,
  }) : super(CrewRequestState(
          user: user,
          loadingState: const Loaded(),
        )) {
    appViewBloc.stream.listen((parentState) {
      add(AppViewUserUpdatedCrewEvent(user: parentState.user));
    });
    on<InitCrewRequestEvent>(_mapInitCrewRequestEvent);
    on<AppViewUserUpdatedCrewEvent>(_mapAppViewUserUpdatedCrewEvent);
    on<SendCrewRequest>(_mapSendCrewRequest);
    on<AddThirdToCrewRequest>(_mapAddThirdToCrewRequest);
    on<ConfirmCrewRequest>(_mapConfirmCrewRequest);
    on<DeleteCrewRequest>(_mapDeleteCrewRequest);
    on<AddCrewPhoto>(_mapAddCrewPhoto);
    on<RemoveCrew>(_mapRemoveCrew);
  }

  _mapInitCrewRequestEvent(InitCrewRequestEvent event, Emitter<CrewRequestState> emit) {
    Profile user = state.user;
    Crew? crew = user.crew;
    Map<dynamic, Profile>? friends = Map<dynamic, Profile>.from(user.friends ?? {});
    Map<dynamic, CrewRequest>? sentCrewRequests = user.sentCrewRequests;
    Map<dynamic, CrewRequest>? receivedCrewRequests = user.receivedCrewRequests;
    List<dynamic> idsToAvoid = [...?sentCrewRequests?.keys.toList(), ...?receivedCrewRequests?.keys.toList()];
    sentCrewRequests = linkRelatedRequests(sentCrewRequests);
    receivedCrewRequests = sortReceivedCrewRequests(receivedCrewRequests);
    friends.removeWhere((key, value) => idsToAvoid.contains(key) || value.city != user.city); // removes anybody who we have a pending request with, or is not in the right city
    emit(state.copyWith(crew: crew, friends: friends, sentCrewRequests: sentCrewRequests, receivedCrewRequests: receivedCrewRequests));
  }

  _mapAppViewUserUpdatedCrewEvent(AppViewUserUpdatedCrewEvent event, Emitter<CrewRequestState> emit) {
    Profile user = event.user;
    Crew? crew = user.crew;
    bool clearCrew = (crew == null);
    Map<dynamic, Profile>? friends = Map<dynamic, Profile>.from(user.friends ?? {});
    Map<dynamic, CrewRequest>? sentCrewRequests = user.sentCrewRequests;
    Map<dynamic, CrewRequest>? receivedCrewRequests = user.receivedCrewRequests;
    List<dynamic> idsToAvoid = [...?sentCrewRequests?.keys.toList(), ...?receivedCrewRequests?.keys.toList()];
    sentCrewRequests = linkRelatedRequests(sentCrewRequests);
    receivedCrewRequests = sortReceivedCrewRequests(receivedCrewRequests);
    friends.removeWhere((key, value) => idsToAvoid.contains(key) || value.city != user.city);
    emit(state.copyWith(user: user, crew: crew, clearCrew: clearCrew, friends: friends, sentCrewRequests: sentCrewRequests, receivedCrewRequests: receivedCrewRequests));
  }

  _mapSendCrewRequest(SendCrewRequest event, Emitter<CrewRequestState> emit) async {
    Profile currentUser = state.user;
    String friendId = event.friend.id!;
    CrewRequest? crewRequest = await crewRepo.sendCrewRequest(currentUser, friendId);
    if (crewRequest != null) {
      Map<dynamic, CrewRequest> updates = {friendId: crewRequest};
      (currentUser.sentCrewRequests != null) ? currentUser.sentCrewRequests?.addAll(updates) : currentUser.sentCrewRequests = updates;
    }
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapAddThirdToCrewRequest(AddThirdToCrewRequest event, Emitter<CrewRequestState> emit) async {
    Profile currentUser = state.user;
    String crewId = event.request.crewId!;
    String friendId = event.friend.id!;
    CrewRequest? crewRequest = await crewRepo.addThirdToCrewRequest(crewId, friendId);
    if (crewRequest != null) {
      Map<dynamic, CrewRequest> updates = {friendId: crewRequest};
      (currentUser.sentCrewRequests != null) ? currentUser.sentCrewRequests?.addAll(updates) : currentUser.sentCrewRequests = updates;
    }
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapConfirmCrewRequest(ConfirmCrewRequest event, Emitter<CrewRequestState> emit) async {
    Profile currentUser = state.user;
    Crew? crew = await crewRepo.confirmCrewRequest(event.request, currentUser, event.friend);
    currentUser.receivedCrewRequests?.remove(event.friend.id);
    currentUser.crew = crew;
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapDeleteCrewRequest(DeleteCrewRequest event, Emitter<CrewRequestState> emit) async {
    Profile currentUser = state.user;
    await crewRepo.deleteCrewRequest(event.request.id!);
    if (event.request.relatedRequest != null) {
      String relatedUserId = event.request.relatedRequest!.friend!.id!;
      currentUser.sentCrewRequests?[relatedUserId]?.relatedRequest = null;
    }
    currentUser.sentCrewRequests?.remove(event.request.friend!.id);
    currentUser.receivedCrewRequests?.remove(event.request.friend!.id);
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapAddCrewPhoto(AddCrewPhoto event, Emitter<CrewRequestState> emit) async {
    Crew? crew = state.crew;
    Profile currentUser = state.user;
    await crewRepo.addCrewPhoto(event.crew.id!, event.url);
    crew!.groupPhotoUrl = event.url;
    currentUser.crew = crew;
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapRemoveCrew(RemoveCrew event, Emitter<CrewRequestState> emit) async {
    Profile currentUser = state.user;
    await crewRepo.removeCrew(event.crew.id!);
    currentUser.crew = null;
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }
}
