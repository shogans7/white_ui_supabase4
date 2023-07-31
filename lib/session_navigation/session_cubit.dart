import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/session_navigation/session_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/auth_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/droptime_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/crew_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/venues_repository.dart';

class SessionCubit extends Cubit<SessionState> {
  int rangeStart = 0;
  int rangeEnd = 10;
  final supabase = Supabase.instance.client;
  final oneSignal = OneSignal();
  final AuthRepository authRepo;
  final CrewRepository crewRepo;
  final LikesRepository likesRepo;
  final FriendsRepository friendsRepo;
  final StorageRepository storageRepo;
  final DroptimeRepository dropRepo;
  final VenueRepository venueRepo;

  SessionCubit({required this.authRepo, required this.crewRepo, required this.likesRepo, required this.friendsRepo, required this.storageRepo, required this.dropRepo, required this.venueRepo})
      : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final userProfile = await authRepo.attemptAutoLogin();
      if (userProfile == null) {
        throw Exception('User not logged in');
      }

      if (isUserProfileUpdated(userProfile)) {
        DateTime? droptime = await dropRepo.getDroptime();
        List<Crew>? crews = await crewRepo.getCrews(userProfile, rangeStart, rangeEnd);
        await oneSignal.setExternalUserId(userProfile.id!);
        emit(Authenticated(userProfile: userProfile, droptime: droptime, crews: crews));
      } else {
        emit(Onboarding(userProfile: userProfile));
      }
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());

  void showSession() async {
    try {
      String userId = supabase.auth.currentUser!.id;
      Profile? userProfile = await authRepo.getProfileFromUserId(userId);
      if (userProfile == null) {
        throw Exception('User not logged in');
      }

      if (isUserProfileUpdated(userProfile)) {
        DateTime? droptime = await dropRepo.getDroptime();
        List<Crew>? crews = await crewRepo.getCrews(userProfile, rangeStart, rangeEnd);
        await oneSignal.setExternalUserId(userProfile.id!);
        emit(Authenticated(userProfile: userProfile, droptime: droptime, crews: crews));
      } else {
        emit(Onboarding(userProfile: userProfile));
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void finishedOnboarding(Profile? userProfile) async {
    DateTime? droptime = await dropRepo.getDroptime();
    List<Crew>? crews = await crewRepo.getCrews(userProfile!, rangeStart, rangeEnd);
    emit(Authenticated(userProfile: userProfile, droptime: droptime, crews: crews));
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}
