import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class CrewRequestEvent {}

class InitCrewRequestEvent extends CrewRequestEvent {}

class AppViewUserUpdatedCrewEvent extends CrewRequestEvent {
  Profile user;

  AppViewUserUpdatedCrewEvent({required this.user});
}

class SendCrewRequest extends CrewRequestEvent {
  final Profile friend;

  SendCrewRequest({required this.friend});
}

class AddThirdToCrewRequest extends CrewRequestEvent {
  final CrewRequest request;
  final Profile friend;

  AddThirdToCrewRequest({required this.request, required this.friend});
}

class ConfirmCrewRequest extends CrewRequestEvent {
  final CrewRequest request;
  final Profile friend;

  ConfirmCrewRequest({required this.request, required this.friend});
}

class DeleteCrewRequest extends CrewRequestEvent {
  final CrewRequest request;
  // final Profile friend;

  DeleteCrewRequest({required this.request});
}

class AddCrewPhoto extends CrewRequestEvent {
  Crew crew;
  String url;

  AddCrewPhoto({required this.crew, required this.url});
}

class RemoveCrew extends CrewRequestEvent {
  Crew crew;

  RemoveCrew({required this.crew});
}
