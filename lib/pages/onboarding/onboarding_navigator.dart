import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';

import 'package:white_ui_supabase4/pages/onboarding/onboarding_cubit.dart';
import 'package:white_ui_supabase4/pages/onboarding/onboarding_state.dart';
import 'package:white_ui_supabase4/pages/onboarding/screens/contacts_screen.dart';
import 'package:white_ui_supabase4/pages/onboarding/screens/profile_photo_screen.dart';
import 'package:white_ui_supabase4/pages/onboarding/screens/update_profile_screen.dart';

class OnboardingNavigator extends StatelessWidget {
  const OnboardingNavigator({Key? key}) : super(key: key);

  static Page<void> page() => const MaterialPage<void>(child: OnboardingNavigator());

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(builder: (context, state) {
      return Navigator(
        pages: [
          if (state == OnboardingState.contacts) MaterialPage(child: ContactsScreen(friendsRepo: context.read<FriendsRepository>())),
          if (state == OnboardingState.profilePhoto)
            MaterialPage(
                child: ProfilePhotoScreen(
              storageRepo: context.read<StorageRepository>(),
            )),
          if (state == OnboardingState.profileDetails) const MaterialPage(child: UpdateProfileScreen()),
        ],
        onPopPage: (route, result) => route.didPop(result),
      );
    });
  }
}
