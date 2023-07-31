import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final AppViewBloc appViewBloc;
  final FriendsRepository friendsRepo;
  final StorageRepository storageRepo;

  FriendsBloc({
    required this.appViewBloc,
    required this.friendsRepo,
    required this.storageRepo,
    required Profile user,
  }) : super(FriendsState(
          user: user,
        )) {
    appViewBloc.stream.listen((parentState) {
      add(AppViewUserUpdatedFriendsEvent(user: parentState.user));
    });
    on<InitFriendsEvent>(_mapInitFriendsEvent);
    on<AppViewUserUpdatedFriendsEvent>(_mapAppViewUserUpdatedFriendsEvent);
    on<FriendsResetFormStatus>(_mapFriendsResetFormStatus);
    on<FriendsReloadEvent>(_mapFriendsReloadEvent);
    on<LoadMoreSuggestedFriends>(_mapLoadMoreSuggestedFriends);
    on<FriendRequestListenerEvent>(_mapFriendRequestListenerEvent);
    on<SendFriendRequest>(_mapSendFriendRequest);
    on<ConfirmFriendRequest>(_mapConfirmFriendRequest);
    on<DeleteFriendRequest>(_mapDeleteFriendRequest);
    on<InviteContactToBuzz>(_mapInviteContactToBuzz);
  }

  _mapInitFriendsEvent(InitFriendsEvent event, Emitter<FriendsState> emit) async {
    String userId = state.user.id!;
    Map<dynamic, Profile>? friends = state.user.friends;
    Map<dynamic, FriendRequest>? receivedFriendRequestsMap = state.user.receivedFriendRequests;
    List<FriendRequest>? receivedFriendRequests = receivedFriendRequestsMap?.values.toList();
    Map<dynamic, FriendRequest>? sentFriendRequestsMap = state.user.sentFriendRequests;
    List<dynamic>? userIdsToNotShowAsContactSuggestions = {
      ...?receivedFriendRequestsMap?.keys.toList(),
      ...?sentFriendRequestsMap?.keys.toList(),
      ...[state.user.id]
    }.toList();
    Map<dynamic, Profile>? buzzUsersInConacts = state.user.buzzUsersInContacts;
    buzzUsersInConacts?.removeWhere((key, value) => userIdsToNotShowAsContactSuggestions.contains(key));
    Map<dynamic, dynamic>? otherContacts = state.user.otherContacts;

    List<dynamic>? userIdsToNotShowAsFriendSuggestions = {
      ...?friends?.keys.toList(),
      ...?receivedFriendRequestsMap?.keys.toList(),
      ...?sentFriendRequestsMap?.keys.toList(),
      ...?buzzUsersInConacts?.keys.toList(),
      ...[userId]
    }.toList();

    Map<dynamic, Profile>? potentialFriends = getFriendsOfFriendsFromFriends(friends, userIdsToNotShowAsFriendSuggestions);
    if (potentialFriends!.isEmpty) {
      potentialFriends = await friendsRepo.loadMoreSuggestedFriends(userIdsToNotShowAsFriendSuggestions, 0, 9);
      emit(state.copyWith(loadMoreSuggestedFriendsIndex: 9));
    }
    emit(state.copyWith(potentialFriends: potentialFriends, receivedFriendRequests: receivedFriendRequests, friends: friends, buzzUsersInContacts: buzzUsersInConacts, otherContacts: otherContacts));
    emit(state.copyWith(loadingState: const Loaded()));
  }

  _mapAppViewUserUpdatedFriendsEvent(AppViewUserUpdatedFriendsEvent event, Emitter<FriendsState> emit) {
    Profile newUser = event.user;
    Map<dynamic, Profile>? previousPotentialFriends = state.potentialFriends;
    Map<dynamic, Profile>? friends = newUser.friends;
    Map<dynamic, FriendRequest>? receivedFriendRequestsMap = newUser.receivedFriendRequests;
    List<FriendRequest>? receivedFriendRequests = receivedFriendRequestsMap?.values.toList();
    Map<dynamic, FriendRequest>? sentFriendRequestsMap = newUser.sentFriendRequests;
    List<dynamic>? userIdsToNotShowAsContactSuggestions = {
      ...?receivedFriendRequestsMap?.keys.toList(),
      ...?sentFriendRequestsMap?.keys.toList(),
      ...[state.user.id]
    }.toList();
    Map<dynamic, Profile>? buzzUsersInContacts = newUser.buzzUsersInContacts;
    buzzUsersInContacts?.removeWhere((key, value) => userIdsToNotShowAsContactSuggestions.contains(key));
    Map<dynamic, dynamic>? otherContacts = newUser.otherContacts;

    List<dynamic>? userIdsToNotShowAsFriendSuggestions = {
      ...?friends?.keys.toList(),
      ...?receivedFriendRequestsMap?.keys.toList(),
      ...?sentFriendRequestsMap?.keys.toList(),
      ...?buzzUsersInContacts?.keys.toList(),
      ...[state.user.id]
    }.toList();

    Map<dynamic, Profile>? potentialFriends = getFriendsOfFriendsFromFriends(friends, userIdsToNotShowAsFriendSuggestions);
    if (previousPotentialFriends != null && potentialFriends != null) {
      if (state.loadMoreSuggestedFriendsIndex > 0) {
        userIdsToNotShowAsFriendSuggestions.addAll(potentialFriends.keys);
        previousPotentialFriends.removeWhere((key, value) => userIdsToNotShowAsFriendSuggestions.contains(key));
        potentialFriends.addAll(previousPotentialFriends);
      }
    }
    emit(state.copyWith(potentialFriends: potentialFriends, receivedFriendRequests: receivedFriendRequests, friends: friends, buzzUsersInContacts: buzzUsersInContacts, otherContacts: otherContacts));
  }

  _mapFriendsResetFormStatus(FriendsResetFormStatus event, Emitter<FriendsState> emit) {
    emit(state.copyWith(formStatus: const InitialFormStatus()));
  }

  _mapFriendsReloadEvent(FriendsReloadEvent event, Emitter<FriendsState> emit) async {
    emit(state.copyWith(loadingState: const Loading()));
    String userId = supabase.auth.currentUser!.id;
    Profile? user = await friendsRepo.getUserAndFriendshipRelationshipsFromUserId(userId);
    if (user != null) {
      appViewBloc.add(AppViewUserUpdatedEvent(user: user));
    }
    emit(state.copyWith(loadingState: const Loaded()));
  }

  _mapLoadMoreSuggestedFriends(LoadMoreSuggestedFriends event, Emitter<FriendsState> emit) async {
    String userId = state.user.id!;
    int rangeStart = state.loadMoreSuggestedFriendsIndex;
    int rangeEnd = rangeStart + 9;
    Map<dynamic, Profile>? friendsMap = state.user.friends;
    Map<dynamic, FriendRequest>? receivedFriendRequestsMap = state.user.receivedFriendRequests;
    Map<dynamic, FriendRequest>? sentFriendRequestsMap = state.user.sentFriendRequests;
    Map<dynamic, Profile>? potentialFriends = state.potentialFriends;
    Map<dynamic, Profile>? buzzUsersInContacts = state.buzzUsersInContacts;
    int friendsOfFriendsEndIndex = potentialFriends!.values.length - rangeStart;

    List<dynamic>? idsToAvoid = {
      ...?friendsMap?.keys.toList(),
      ...?receivedFriendRequestsMap?.keys.toList(),
      ...?sentFriendRequestsMap?.keys.toList(),
      ...potentialFriends.keys.toList().getRange(0, friendsOfFriendsEndIndex), // not the smoothest ?
      ...?buzzUsersInContacts?.keys.toList(),
      ...[userId]
    }.toList();

    Map<dynamic, Profile>? moreSuggestedFriends = await friendsRepo.loadMoreSuggestedFriends(idsToAvoid, rangeStart, rangeEnd);
    if (moreSuggestedFriends != null) {
      potentialFriends.addAll(moreSuggestedFriends);
      int numberOfSuggestionsReturned = moreSuggestedFriends.values.length;
      emit(state.copyWith(loadMoreSuggestedFriendsIndex: rangeStart + numberOfSuggestionsReturned));
    }
    emit(state.copyWith(potentialFriends: potentialFriends));
  }

  _mapFriendRequestListenerEvent(FriendRequestListenerEvent event, Emitter<FriendsState> emit) async {
    Profile currentUser = state.user;
    FriendRequest friendRequest = FriendRequest.fromJson(event.data['new']);
    if (currentUser.id == friendRequest.receiverId) {
      if (friendRequest.status == 'request') {
        List<dynamic> existingRequestIds = currentUser.receivedFriendRequests?.keys.toList() ?? [];
        if (!existingRequestIds.contains(friendRequest.senderId)) {
          Profile? friendRequestSender = await getUserById(friendRequest.senderId!);
          friendRequest.friend = friendRequestSender;
          Map<dynamic, FriendRequest> updates = {friendRequest.senderId: friendRequest};
          (currentUser.receivedFriendRequests != null) ? currentUser.receivedFriendRequests?.addAll(updates) : currentUser.receivedFriendRequests = updates;
        }
      }
    }
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapSendFriendRequest(SendFriendRequest event, Emitter<FriendsState> emit) async {
    Profile currentUser = state.user;
    String friendId = event.friend.id!;
    if (event.user != null) {
      FriendRequest? friendRequest = await friendsRepo.sendFriendRequest(friendId);
      if (friendRequest != null) {
        Map<dynamic, FriendRequest> updates = {friendId: friendRequest};
        (currentUser.sentFriendRequests != null) ? currentUser.sentFriendRequests?.addAll(updates) : currentUser.sentFriendRequests = updates;
      }
    }
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
    if (state.loadMoreSuggestedFriendsIndex > 0) {
      emit(state.copyWith(loadMoreSuggestedFriendsIndex: state.loadMoreSuggestedFriendsIndex - 1));
    }
  }

  _mapConfirmFriendRequest(ConfirmFriendRequest event, Emitter<FriendsState> emit) async {
    Profile currentUser = state.user;
    await friendsRepo.acceptFriendRequest(event.requestId, event.friend.id!);
    currentUser.receivedFriendRequests?.remove(event.friend.id);
    Map<dynamic, Profile> updates = {event.friend.id: event.friend};
    (currentUser.friends != null) ? currentUser.friends?.addAll(updates) : currentUser.friends = updates;
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapDeleteFriendRequest(DeleteFriendRequest event, Emitter<FriendsState> emit) async {
    Profile currentUser = state.user;
    await friendsRepo.deleteFriendRequest(event.requestId!);
    currentUser.receivedFriendRequests?.remove(event.friend.id);
    appViewBloc.add(AppViewUserUpdatedEvent(user: currentUser));
  }

  _mapInviteContactToBuzz(InviteContactToBuzz event, Emitter<FriendsState> emit) async {
    // TODO: implement twilio invite contacts funcitonality
  }
}
