import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friendship.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_state.dart';

class AppViewBloc extends Bloc<AppViewEvent, AppViewState> {
  final CrewRepository crewRepo;
  // final SessionCubit sessionCubit;

  AppViewBloc({
    required this.crewRepo,
    required Profile user,
  }) : super(AppViewState(
          user: user,
        )) {
    on<InitAppEvent>(_mapInitAppEvent);
    on<PendingMatchListenerEvent>(_mapPendingMatchListenerEvent);
    // on<MatchListenerEvent>(_mapMatchListenerEvent);
    on<ClearGroup>(_mapClearGroup);
    on<UpdateIndexEvent>(_mapUpdateIndexEvent);
    on<AppViewUserUpdatedEvent>(_mapUpdateUser);
    on<FriendshipListenerEvent>(_mapFriendshipListenerEvent);
    on<CrewListenerEvent>(_mapCrewListenerEvent);
  }

  _mapInitAppEvent(InitAppEvent event, Emitter<AppViewState> emit) async {
    var contactBox = await Hive.openBox('contacts');
    Map? contactsMap = await separateBuzzUsersAndContacts(contactsMap: contactBox.toMap(), getBuzzUsersFriends: true);
    Map<dynamic, Profile>? contactsBuzzUsers = contactsMap!['buzzUsers'];
    Map<dynamic, dynamic>? otherContacts = contactsMap['otherContacts'];
    Profile currentUser = state.user;
    currentUser.buzzUsersInContacts = contactsBuzzUsers;
    currentUser.otherContacts = otherContacts;
    emit(state.copyWith(user: currentUser));
  }

  /*
      // DateTime? dropTime = await dropRepo.getDropTime();
    // print("Droptime is: " + dropTime.toString());
    // if (dropTime != null) {
    //   DateTime currentDateTime = DateTime.now();
    //   Duration diff = dropTime.difference(currentDateTime);
    //   int secondsUntil = diff.inSeconds;
    //   print("Notification in " + secondsUntil.toString() + " seconds");
    //   if (secondsUntil > 0) {
    //     NotificationService().showNotification(title: "Buzz has gone LIVE!!", body: "Get swiping, its first come first served around here!", secondsUntil: secondsUntil);
    //   } else {
    //     NotificationService().showNotification(title: "Buzz has gone LIVE!!", body: "Get swiping, its first come first served around here!");
    //   }
    // }

  */

  _mapPendingMatchListenerEvent(PendingMatchListenerEvent event, Emitter<AppViewState> emit) async {
    // MatchConfirmation matchConfirmation = MatchConfirmation.fromJson(event.data);
    // if (state.user.id! == matchConfirmation.userId) {
    //   if (matchConfirmation.confirmed == null && matchConfirmation.groupId != null) {
    //     Group? otherGroup = await getGroupById(matchConfirmation.groupId!);
    //     if (otherGroup != null) {
    //       emit(state.copyWith(matchedGroup: otherGroup, clearGroup: false));
    //     }
    //   }
    // }
  }

  _mapClearGroup(ClearGroup event, Emitter<AppViewState> emit) {
    emit(state.copyWith(clearGroup: true));
  }

  _mapUpdateIndexEvent(UpdateIndexEvent event, Emitter<AppViewState> emit) async {
    await Future.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(screenIndex: event.index));
  }

  // _mapChangeOnboardingState(ChangeOnboardingState event, Emitter<AppViewState> emit) {
  //   print("Changing show contacts state to " + event.onboardingState.toString());
  //   emit(state.copyWith(onboardingState: event.onboardingState));
  // }

  _mapUpdateUser(AppViewUserUpdatedEvent event, Emitter<AppViewState> emit) async {
    Profile originalUser = state.user;
    Profile updatedUser = event.user;
    if (event.includesFriendData != null && event.includesFriendData == false) {
      updatedUser = overlayFriendsOnUpdatedUser(originalUser: originalUser, updatedUser: updatedUser);
    }
    emit(state.copyWith(user: updatedUser));
  }

  _mapFriendshipListenerEvent(FriendshipListenerEvent event, Emitter<AppViewState> emit) async {
    Profile currentUser = state.user;
    try {
      Friendship friendship = Friendship.fromJson(event.data['new']);
      List<dynamic> existingFriendIds = currentUser.friends!.keys.toList();

      if (!existingFriendIds.contains(friendship.friendId)) {
        Profile? friend = await getUserById(friendship.friendId!, withFriends: true);
        if (friend != null) {
          String id = friend.id!;
          currentUser.friends![id] = friend;
          currentUser.receivedFriendRequests!.remove(id);
          currentUser.sentFriendRequests!.remove(id);
        }
      }
    } catch (e) {
      Exception("Could not parse friendship from channel payload");
    }
    emit(state.copyWith(user: currentUser));
  }

  _mapCrewListenerEvent(CrewListenerEvent event, Emitter<AppViewState> emit) async {
    /*
      Note for when change from realtime to db webhooks
      Need to listen to deletes as well as inserts (as other user remove group important!)
    */

    Profile currentUser = state.user;
    try {
      Crew crew = Crew.fromJson(event.data['new']);
      if (state.user.crew != null) {
        Crew? crewWithProfiles = await getProfilesForCrew(crew);
        if (crewWithProfiles != null) {
          currentUser.crew = crewWithProfiles;
        }
      } else {
        throw Exception("We've already got a crew");
      }
    } catch (e) {
      Exception("Could not parse crew from channel payload");
    }
    emit(state.copyWith(user: currentUser));
  }
}
