import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class ProfileViewEvent {}

class InitViewProfileEvent extends ProfileViewEvent {}

class AppViewUserUpdatedProfileEvent extends ProfileViewEvent {
  Profile user;

  AppViewUserUpdatedProfileEvent({required this.user});
}

class ProfileReloadEvent extends ProfileViewEvent {}
