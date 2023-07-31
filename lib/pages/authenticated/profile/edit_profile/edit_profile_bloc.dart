import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/edit_profile/edit_profile_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/edit_profile/edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final AppViewBloc appViewBloc;
  final _picker = ImagePicker();
  final StorageRepository storageRepo;
  final LikesRepository likesRepo;

  EditProfileBloc({
    required this.appViewBloc,
    required this.storageRepo,
    required this.likesRepo,
    required Profile userProfile,
  }) : super(EditProfileState(
          userProfile: userProfile,
          loadingState: const Loaded(),
        )) {
    appViewBloc.stream.listen((parentState) {
      add(AppViewUserUpdatedEditProfileEvent(user: parentState.user));
    });
    on<AppViewUserUpdatedEditProfileEvent>(_mapAppViewUserUpdatedEditProfileEvent);
    on<ChangeAvatarRequest>(_mapChangeAvatarRequest);
    on<OpenImagePicker>(_mapOpenImagePicker);
    on<ProfileUsernameChanged>(_mapProfileUsernameChanged);
    on<ProfileDescriptionChanged>(_mapProfileDescriptionChanged);
    on<CityChanged>(_mapCityChanged);
    on<HomeTownChanged>(_mapHomeTownChanged);
    // on<CityChanged>(_mapCityChanged);
    on<GenderChanged>(_mapGenderChanged);
    on<InterestedInChanged>(_mapInterestedInChanged);
    on<BirthdayChanged>(_mapBirthdayChanged);
    on<OccupationChanged>(_mapOccupationChanged);
    on<UniversityChanged>(_mapUniversityChanged);
    on<SaveProfileChanges>(_mapSaveProfileChanges);
    on<ResetFormStatus>(_mapResetFormStatus);
    on<EditProfileReloadEvent>(_mapEditProfileReloadEvent);
  }

  _mapAppViewUserUpdatedEditProfileEvent(AppViewUserUpdatedEditProfileEvent event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(userProfile: event.user));
  }

  _mapResetFormStatus(ResetFormStatus event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(formStatus: const InitialFormStatus()));
  }

  _mapChangeAvatarRequest(ChangeAvatarRequest event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(imageSourceActionSheetIsVisible: true));
  }

  _mapOpenImagePicker(OpenImagePicker event, Emitter<EditProfileState> emit) async {
    emit(state.copyWith(imageSourceActionSheetIsVisible: false));
    final pickedImage = await _picker.pickImage(source: event.imageSource);
    if (pickedImage == null) {
      return;
    }

    String? imageUrl = state.getImageURL;
    if (imageUrl != null) {
      debugPrint("Evicting imageUrl");
      await CachedNetworkImage.evictFromCache(imageUrl);
    }
    if (state.userProfile.avatarUrl != null) {
      debugPrint("Evicting userProfileUrl");
      await CachedNetworkImage.evictFromCache(state.userProfile.avatarUrl!);
    }

    String? imageURL = await storageRepo.uploadFile(pickedImage);
    emit(state.copyWith(imageURL: imageURL));

    User? user = supabase.auth.currentUser;
    if (user != null) {
      Profile? userProfile = await getUserById(user.id);
      if (userProfile != null) {
        emit(state.copyWith(userProfile: userProfile));
      }
    }
  }

  _mapProfileUsernameChanged(ProfileUsernameChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(name: event.name));
  }

  _mapProfileDescriptionChanged(ProfileDescriptionChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(userDescription: event.description));
  }

  _mapCityChanged(CityChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(city: event.city));
  }

  _mapHomeTownChanged(HomeTownChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(homeTown: event.homeTown));
  }

  _mapGenderChanged(GenderChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(gender: event.gender));
  }

  _mapInterestedInChanged(InterestedInChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(interestedIn: event.interestedIn));
  }

  _mapBirthdayChanged(BirthdayChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(birthday: event.birthday));
  }

  _mapOccupationChanged(OccupationChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(occupation: event.occupation));
  }

  _mapUniversityChanged(UniversityChanged event, Emitter<EditProfileState> emit) {
    emit(state.copyWith(university: event.university));
  }

  _mapSaveProfileChanges(SaveProfileChanges event, Emitter<EditProfileState> emit) async {
    emit(state.copyWith(formStatus: FormSubmitting()));

    String? birthdate = state.birthday?.toString().split(" ")[0];
    final updates = {
      'id': state.userProfile.id,
      'full_name': state.name,
      'bio': state.userDescription,
      'city': state.city,
      'homeTown': state.homeTown,
      'neighbourhood': state.neighbourhood,
      'gender': state.gender,
      'interestedIn': state.interestedIn,
      'birthday': birthdate,
      'occupation': state.occupation,
      'university': state.university,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      final supabase = Supabase.instance.client;
      final data = await supabase.from('profiles').upsert(updates).select().single();
      if (data.isNotEmpty) {
        Profile updatedUser = Profile.fromJson(data);
        appViewBloc.add(AppViewUserUpdatedEvent(user: updatedUser, includesFriendData: false));
      }
      emit(state.copyWith(formStatus: SubmissionSuccess()));
    } catch (e) {
      emit(state.copyWith(formStatus: SubmissionFailed(Exception(e))));
    }
  }

  _mapEditProfileReloadEvent(EditProfileReloadEvent event, Emitter<EditProfileState> emit) async {
    emit(state.copyWith(loadingState: const Loading()));
    final supabase = Supabase.instance.client;
    debugPrint("Profile reload event called");
    if (state.imageURL != null) {
      debugPrint("Evicting cached image");
      await CachedNetworkImage.evictFromCache(state.imageURL!);
    }
    if (state.userProfile.avatarUrl != null) {
      debugPrint("Evicting cached image profile url");
      await CachedNetworkImage.evictFromCache(state.userProfile.avatarUrl!);
    }

    User? user = supabase.auth.currentUser;
    if (user != null) {
      Profile? userProfile = await getUserById(user.id);
      if (userProfile != null) {
        emit(state.copyWith(
          userProfile: userProfile,
        ));
      }
    }
    emit(state.copyWith(loadingState: const Loaded()));
  }
}
