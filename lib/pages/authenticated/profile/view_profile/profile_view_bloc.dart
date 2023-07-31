import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_state.dart';

class ProfileViewBloc extends Bloc<ProfileViewEvent, ProfileViewState> {
  final AppViewBloc appViewBloc;
  final LikesRepository likesRepo;

  ProfileViewBloc({
    required this.appViewBloc,
    required this.likesRepo,
    required Profile currentUser,
    required Profile userProfile,
  }) : super(ProfileViewState(
          currentUser: currentUser,
          userProfile: userProfile,
          loadingState: const Loading(),
          additionalDataLoadingState: const Loaded(),
        )) {
    appViewBloc.stream.listen((parentState) {
      add(AppViewUserUpdatedProfileEvent(user: parentState.user));
    });
    on<InitViewProfileEvent>(_mapInitViewProfileEvent);
    on<AppViewUserUpdatedProfileEvent>(_mapAppViewUserUpdatedProfileEvent);
    on<ProfileReloadEvent>(_mapProfileReloadEvent);
  }

  _mapInitViewProfileEvent(InitViewProfileEvent event, Emitter<ProfileViewState> emit) async {
    Profile? currentUser = state.currentUser;
    Profile userProfile = state.userProfile;
    bool isCurrentUser = (currentUser == userProfile);
    bool? alreadyFriends = currentUser.friends?.keys.contains(userProfile.id);
    FriendRequest? sentFriendRequest = currentUser.sentFriendRequests?[userProfile.id];
    FriendRequest? receivedFriendRequest = currentUser.receivedFriendRequests?[userProfile.id];
    FriendshipState friendshipState = (isCurrentUser)
        ? FriendshipState.currentUser
        : (alreadyFriends != null && alreadyFriends)
            ? FriendshipState.friends
            : (sentFriendRequest != null)
                ? FriendshipState.sentRequest
                : (receivedFriendRequest != null)
                    ? FriendshipState.receivedRequest
                    : FriendshipState.none;
    FriendRequest? friendRequest = (sentFriendRequest != null)
        ? sentFriendRequest
        : (receivedFriendRequest != null)
            ? receivedFriendRequest
            : null;
    emit(state.copyWith(currentUser: currentUser, userProfile: userProfile, friendshipState: friendshipState, friendRequest: friendRequest, loadingState: const Loaded()));

    List<Like>? sentLikesHistory;
    List<Match>? matchHistory;
    Profile? user = await getUsersFriendsAndCrewAndMatchesAndLikesFromId(userProfile.id!);

    // print("Fetching user match and like history");
    // Map? userMatchAndLikeHistory = await likesRepo.getUserMatchAndLikesHistory(userProfile.id!);
    // if (userMatchAndLikeHistory != null) {
    //   print("returned non null");
    //   sentLikesHistory = userMatchAndLikeHistory['sentLikesHistory'];
    //   matchHistory = userMatchAndLikeHistory['matchHistory'];
    // }
    emit(state.copyWith(userProfile: user, sentLikesHistory: sentLikesHistory, matchHistory: matchHistory, additionalDataLoadingState: const Loaded()));
  }

  _mapAppViewUserUpdatedProfileEvent(AppViewUserUpdatedProfileEvent event, Emitter<ProfileViewState> emit) {
    Profile? currentUser = event.user;
    Profile userProfile = state.userProfile;
    bool isCurrentUser = (currentUser == userProfile);
    bool? alreadyFriends = currentUser.friends?.keys.contains(userProfile.id);
    FriendRequest? sentFriendRequest = currentUser.sentFriendRequests?[userProfile.id];
    FriendRequest? receivedFriendRequest = currentUser.receivedFriendRequests?[userProfile.id];
    FriendshipState friendshipState;
    FriendRequest? friendRequest;
    friendshipState = (isCurrentUser)
        ? FriendshipState.currentUser
        : (alreadyFriends != null && alreadyFriends)
            ? FriendshipState.friends
            : (sentFriendRequest != null)
                ? FriendshipState.sentRequest
                : (receivedFriendRequest != null)
                    ? FriendshipState.receivedRequest
                    : FriendshipState.none;
    friendRequest = (sentFriendRequest != null)
        ? sentFriendRequest
        : (receivedFriendRequest != null)
            ? receivedFriendRequest
            : null;
    emit(state.copyWith(currentUser: currentUser, userProfile: userProfile, friendshipState: friendshipState, friendRequest: friendRequest));
  }

  _mapProfileReloadEvent(ProfileReloadEvent event, Emitter<ProfileViewState> emit) async {
    emit(state.copyWith(loadingState: const Loading()));
    // final supabase = Supabase.instance.client;
    // print("Profile reload event called");
    // if (state.imageURL != null) {
    //   print("Evicting cached image");
    //   await CachedNetworkImage.evictFromCache(state.imageURL!);
    // }
    // if (state.userProfile!.avatarUrl != null) {
    //   print("Evicting cached image profile url");
    //   await CachedNetworkImage.evictFromCache(state.userProfile!.avatarUrl!);
    // }

    // User? user = supabase.auth.currentUser;
    // if (user != null) {
    //   Profile? userProfile = await getUserById(user.id);
    //   if (userProfile != null) {
    //     emit(state.copyWith(
    //       userProfile: userProfile,
    //     ));
    //   }
    // }
    emit(state.copyWith(loadingState: const Loaded()));
  }
}
