import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class SessionState {
  Profile? sessionUserProfile;
  Profile? get user => sessionUserProfile;
  DateTime? sessionDroptime;
  DateTime? get droptime => sessionDroptime;
  List<Crew>? initialCrews;
  List<Crew>? get groups => initialCrews;
}

class UnknownSessionState extends SessionState {}

class Unauthenticated extends SessionState {}

class Onboarding extends SessionState {
  Onboarding({required Profile? userProfile}) {
    sessionUserProfile = userProfile;
  }
}

class Authenticated extends SessionState {
  Authenticated({required Profile? userProfile, required DateTime? droptime, required List<Crew>? crews}) {
    sessionUserProfile = userProfile;
    sessionDroptime = droptime;
    initialCrews = crews;
  }
}
