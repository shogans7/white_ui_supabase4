import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class MeetEvent {}

class InitMeetEvent extends MeetEvent {
  List<Crew> initialCrews;

  InitMeetEvent({required this.initialCrews});
}

class AppViewUserUpdatedMeetEvent extends MeetEvent {
  final Profile user;

  AppViewUserUpdatedMeetEvent({required this.user});
}

class LoadMoreCrewsEvent extends MeetEvent {}

class RefreshCrewsAlreadySwipedEvent extends MeetEvent {}

class SendLikeEvent extends MeetEvent {
  Profile? user;
  Crew? currentCrew;
  Crew? otherCrew;
  bool? like;

  SendLikeEvent({required this.user, this.currentCrew, required this.otherCrew, required this.like});
}

class CrewRequestListenerEvent extends MeetEvent {
  Map<dynamic, dynamic> data;

  CrewRequestListenerEvent({required this.data});
}

class MatchListenerEvent extends MeetEvent {
  Map<dynamic, dynamic> data;

  MatchListenerEvent({required this.data});
}

class ResetFormStatus extends MeetEvent {}

class ChangeIndex extends MeetEvent {
  int index;

  ChangeIndex({required this.index});
}

class ButtonPressed extends MeetEvent {
  bool pressed;

  ButtonPressed({required this.pressed});
}

class UpdateSelectedVenues extends MeetEvent {}
