import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class EditProfileState {
  final Profile userProfile;
  final LoadingState loadingState;

  final String? name;
  String? imageURL;
  final String? userDescription;
  final String? city;
  final String? homeTown;
  final String? neighbourhood;
  final String? gender;
  final String? interestedIn;
  final DateTime? birthday;
  final String? occupation;
  final String? university;

  String get email => "email";
  String? get getImageURL => imageURL ?? userProfile.avatarUrl;

  final FormSubmissionStatus formStatus;
  bool imageSourceActionSheetIsVisible;

  EditProfileState({
    required this.userProfile,
    this.loadingState = const Loading(),
    String? name,
    String? imageURL,
    String? userDescription,
    String? city,
    String? homeTown,
    String? neighbourhood,
    String? gender,
    String? interestedIn,
    DateTime? birthday,
    String? occupation,
    String? university,
    this.formStatus = const InitialFormStatus(),
    this.imageSourceActionSheetIsVisible = false,
    Map? friends,
  })  : name = name ?? capitalise(userProfile.name),
        city = city ?? userProfile.city,
        homeTown = homeTown ?? userProfile.homeTown,
        neighbourhood = neighbourhood ?? userProfile.neighbourhood,
        gender = gender ?? userProfile.gender,
        interestedIn = interestedIn ?? userProfile.interestedIn,
        birthday = birthday ?? userProfile.birthday, //== Null ? DateTime.fromMillisecondsSinceEpoch(1 /*userProfile.birthday*/) : null),
        occupation = occupation ?? userProfile.occupation,
        university = university ?? userProfile.university,
        userDescription = userDescription ?? userProfile.bio;

  EditProfileState copyWith({
    Profile? userProfile,
    LoadingState? loadingState,
    String? name,
    String? userDescription,
    String? city,
    String? homeTown,
    String? neighbourhood,
    String? gender,
    String? interestedIn,
    DateTime? birthday,
    String? occupation,
    String? university,
    String? imageURL,
    FormSubmissionStatus? formStatus,
    bool? imageSourceActionSheetIsVisible,
  }) {
    return EditProfileState(
      userProfile: userProfile ?? this.userProfile,
      loadingState: loadingState ?? this.loadingState,
      imageURL: imageURL ?? this.imageURL,
      name: name ?? this.name,
      userDescription: userDescription ?? this.userDescription,
      city: city ?? this.city,
      homeTown: homeTown ?? this.homeTown,
      neighbourhood: neighbourhood ?? this.neighbourhood,
      gender: gender ?? this.gender,
      interestedIn: interestedIn ?? this.interestedIn,
      birthday: birthday ?? this.birthday,
      occupation: occupation ?? this.occupation,
      university: university ?? this.university,
      formStatus: formStatus ?? this.formStatus,
      imageSourceActionSheetIsVisible: imageSourceActionSheetIsVisible ?? this.imageSourceActionSheetIsVisible,
    );
  }
}
