import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/session_navigation/session_cubit.dart';

import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SessionCubit sessionCubit;
  Profile userProfileUpdates = Profile();

  OnboardingCubit({required this.sessionCubit}) : super(OnboardingState.contacts);

  void updateSentFriendRequests(Map<dynamic, FriendRequest> sentFriendRequests) => userProfileUpdates.sentFriendRequests = sentFriendRequests;
  void updateImageUrl(String imageUrl) => userProfileUpdates.avatarUrl = imageUrl;
  void updateUserProfile(String city, String gender, String interestedIn, {String? description}) {
    userProfileUpdates.city = city;
    userProfileUpdates.gender = gender;
    userProfileUpdates.interestedIn = interestedIn;
    userProfileUpdates.bio = description;
  }

  void showContacts() => emit(OnboardingState.contacts);
  void showProfilePhoto() => emit(OnboardingState.profilePhoto);
  void showProfileDetails() => emit(OnboardingState.profileDetails);

  void finishedOnboarding() {
    Profile user = sessionCubit.state.user!;
    user.avatarUrl = userProfileUpdates.avatarUrl;
    user.city = userProfileUpdates.city;
    user.gender = userProfileUpdates.gender;
    user.interestedIn = userProfileUpdates.interestedIn;
    user.bio = userProfileUpdates.bio;
    user.sentFriendRequests = (user.sentFriendRequests == null) ? userProfileUpdates.sentFriendRequests : {...user.sentFriendRequests!, ...?userProfileUpdates.sentFriendRequests};
    sessionCubit.finishedOnboarding(user);
  }
}
