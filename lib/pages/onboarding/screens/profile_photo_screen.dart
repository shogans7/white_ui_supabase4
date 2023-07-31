// ignore_for_file: implementation_imports

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/src/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/image_source_sheet.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/pages/onboarding/onboarding_cubit.dart';

class ProfilePhotoScreen extends StatefulWidget {
  final StorageRepository storageRepo;
  const ProfilePhotoScreen({Key? key, required this.storageRepo}) : super(key: key);

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final supabase = Supabase.instance.client;
  final picker = ImagePicker();
  bool _photoSelected = false;
  LoadingState loadingState = const Loaded();
  XFile? imageXFile;
  File? imageFile;

  Future<String?> uploadFile() async {
    String? imageURL = await widget.storageRepo.uploadFile(imageXFile!);
    return imageURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Profile Photo'),
        actions: [
          TextButton(
            child: const Text("Skip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            onPressed: () {
              context.read<OnboardingCubit>().showProfileDetails();
              // context.read<AppViewBloc>().add(ChangeOnboardingState(onboardingState: OnboardingState.profileDetails));
            },
          ),
        ],
      ),
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 50,
              ),
              const SizedBox(
                height: 100,
                width: 300,
                child: Text(
                  "Don't leave people guessing, show them how great you look!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Stack(children: [
                GestureDetector(
                    child: Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withOpacity(0.5), width: 1)),
                      child: _photoSelected
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.person,
                                size: 100,
                              ),
                            ),
                    ),
                    onTap: () {
                      showImageSourceActionSheet(context, picker, onSuccess);
                    }),
              ]),
              SizedBox(
                  height: 250,
                  child: Stack(alignment: Alignment.topCenter, children: [
                    Positioned(
                      top: 100,
                      child: (_photoSelected && !(loadingState == const Loading()))
                          ? Center(
                              child: TextButton(
                                child: const Text(
                                  "Choose another photo",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  showImageSourceActionSheet(context, picker, onSuccess);
                                },
                              ),
                            )
                          : Container(),
                    ),
                  ])),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4, bottom: 0.0),
            child: SizedBox(
                width: double.infinity,
                child: SizedBox(
                    height: 100,
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 45.0, left: 10.0, right: 10.0, top: 0.0),
                        child: continueButton(onContinuePressed, loadingState: loadingState, enableButton: _photoSelected)
                        // _continueButton(_photoSelected),
                        ))),
          ),
        ),
      ]),
    );
  }

  void onSuccess(XFile pickedImage) {
    setState(() {
      imageFile = File(pickedImage.path);
      imageXFile = pickedImage;
      _photoSelected = true;
    });
  }

  void onContinuePressed() async {
    if (_photoSelected) {
      setState(() {
        loadingState = const Loading();
      });
      String? imageURL = await uploadFile();
      if (imageURL != null) {
        debugPrint("Success! " + imageURL);
        context.read<OnboardingCubit>().updateImageUrl(imageURL);
        // context.read<AppViewBloc>().add(AppViewUserUpdatedEvent(updates: {"avatar_url": imageURL}));
      }
      setState(() {
        loadingState = const Loaded();
      });
      context.read<OnboardingCubit>().showProfileDetails();
      // context.read<AppViewBloc>().add(ChangeOnboardingState(onboardingState: OnboardingState.profileDetails));
    }
  }
}
