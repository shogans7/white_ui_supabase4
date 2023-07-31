import 'package:image_picker/image_picker.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

abstract class EditProfileEvent {}

class AppViewUserUpdatedEditProfileEvent extends EditProfileEvent {
  Profile user;

  AppViewUserUpdatedEditProfileEvent({required this.user});
}

class ChangeAvatarRequest extends EditProfileEvent {}

class OpenImagePicker extends EditProfileEvent {
  final ImageSource imageSource; // ? or req

  OpenImagePicker({required this.imageSource});
}

class ProfileUsernameChanged extends EditProfileEvent {
  final String name; // ? or req

  ProfileUsernameChanged({required this.name});
}

class ProfileDescriptionChanged extends EditProfileEvent {
  final String description; // ? or req

  ProfileDescriptionChanged({required this.description});
}

class CityChanged extends EditProfileEvent {
  final String? city;

  CityChanged({required this.city});
}

class HomeTownChanged extends EditProfileEvent {
  final String? homeTown;

  HomeTownChanged({required this.homeTown});
}

class NeighbourhoodChanged extends EditProfileEvent {
  final String? neighbourhood;

  NeighbourhoodChanged({required this.neighbourhood});
}

class GenderChanged extends EditProfileEvent {
  final String? gender;

  GenderChanged({required this.gender});
}

class InterestedInChanged extends EditProfileEvent {
  final String? interestedIn;

  InterestedInChanged({required this.interestedIn});
}

class BirthdayChanged extends EditProfileEvent {
  final DateTime? birthday;

  BirthdayChanged({required this.birthday});
}

class OccupationChanged extends EditProfileEvent {
  final String occupation; // ? or req

  OccupationChanged({required this.occupation});
}

class UniversityChanged extends EditProfileEvent {
  final String university; // ? or req

  UniversityChanged({required this.university});
}

class SaveProfileChanges extends EditProfileEvent {}

class ResetFormStatus extends EditProfileEvent {}

class EditProfileReloadEvent extends EditProfileEvent {}
