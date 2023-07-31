import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/likes_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/button_dialog.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/page_loading_view.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/profile_picture.dart';
import 'package:white_ui_supabase4/pages/authenticated/app_view/app_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/edit_profile/edit_profile_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/edit_profile/edit_profile_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/profile/view_profile/profile_view_event.dart';
import 'package:white_ui_supabase4/session_navigation/session_cubit.dart';
import 'edit_profile_event.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditEditProfileState();
}

class _EditEditProfileState extends State<EditProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> cities = [
    "Dublin",
    "Cork",
    "Galway",
    "London",
    "Melbourne",
    "Sydney",
  ];

  List<String> genders = ["Male", "Female", "Other"];
  List<String> interstedInList = ["Men", "Women", "Everyone"];

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<EditProfileBloc>(),
      child: BlocListener<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          if (state.imageSourceActionSheetIsVisible) {
            _showImageSourceActionSheet(context);
          }
          final formStatus = state.formStatus;
          if (formStatus is SubmissionSuccess) {
            showSnackBar(context, "Changes saved succesfully");
            context.read<EditProfileBloc>().add(ResetFormStatus());
          }
          if (formStatus is SubmissionFailed) {
            showSnackBar(context, formStatus.exception.toString());
            context.read<EditProfileBloc>().add(ResetFormStatus());
          }
        },
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: _appBar(),
            body: BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
              return RefreshIndicator(
                  onRefresh: () async {
                    context.read<EditProfileBloc>().add(EditProfileReloadEvent());
                  },
                  child: GestureDetector(onTap: () => FocusScope.of(context).requestFocus(FocusNode()), child: _profilePage()));
            })),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    final appBarHeight = AppBar().preferredSize.height;
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
        final appViewBloc = context.read<AppViewBloc>();
        void onSignOutPressed() async {
          await Future.delayed(const Duration(milliseconds: 750));
          context.read<SessionCubit>().signOut();
        }

        return AppBar(title: const Text('Profile'), backgroundColor: Colors.black87, actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("View Profile"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("Sign Out"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      settings: const RouteSettings(name: "/firstOfChain"),
                      builder: (_) => BlocProvider(
                            create: (context) => ProfileViewBloc(
                              appViewBloc: appViewBloc,
                              likesRepo: context.read<LikesRepository>(),
                              currentUser: state.userProfile,
                              userProfile: state.userProfile,
                            )..add(InitViewProfileEvent()),
                            child: ProfileView(
                              friendsBloc: context.read<FriendsBloc>(),
                            ),
                          )));
            } else if (value == 1) {
              showButtonDialog(context, "Sign out", const Text("Are you sure you want to sign out?"), onConfirmed: onSignOutPressed);
            }
          })
        ]);
      }),
    );
  }

  Widget _profilePage() {
    return SingleChildScrollView(child: BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      final loadingState = state.loadingState;
      void onPressed() => context.read<EditProfileBloc>().add(ChangeAvatarRequest());
      return loadingState is Loading
          ? pageLoadingView()
          : SingleChildScrollView(
              physics: const ScrollPhysics(),
              // SafeArea(
              //     child: SizedBox(
              //     height: MediaQuery.of(context).size.height,
              //     width: MediaQuery.of(context).size.width,
              child: Center(
                child:
                    // Stack(
                    //   alignment: Alignment.topCenter,
                    //   children: [
                    Column(
                  children: [
                    profilePicture(state.getImageURL, onPressed: onPressed),
                    _usernameTile(),
                    _descriptionTile(),
                    // _cityTile(),
                    // _locationTile(),
                    _jobTile(),
                    _educationTile(),
                    _homeTile(),
                    _genderTile(),
                    _interestedInTile(),
                    _birthdayTile(),
                    const SizedBox(height: 10),
                    _editProfileRow(),
                    const SizedBox(height: 10),
                  ],
                ),
                //   ],
                // ),
                // ),
              ));
    }));
  }

  Widget _usernameTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return ListTile(
        tileColor: Colors.white,
        leading: const Icon(Icons.person),
        title:
            // Text(fx.capitalise(state.username)),
            TextFormField(
          // initialValue: "",
          initialValue: state.name,
          decoration: const InputDecoration.collapsed(hintText: "What's your name?"),
          maxLines: null,
          // readOnly: false,
          style: const TextStyle(fontWeight: FontWeight.bold),
          // toolbarOptions: ToolbarOptions(
          //   copy: state.editUser,
          //   cut: state.editUser,
          //   paste: state.editUser,
          //   selectAll: state.editUser,
          // ),
          onChanged: (value) => context.read<EditProfileBloc>().add(ProfileUsernameChanged(name: value)),
        ),
      );
    });
  }

  Widget _cityTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      String? selectedCity;
      return ListTile(
          tileColor: Colors.white,
          leading: const Icon(Icons.location_city),
          title: DropdownButtonFormField<String>(
            menuMaxHeight: MediaQuery.of(context).size.height / 4,
            iconSize: 0.0,
            hint: const Text("Select a city"),
            value: selectedCity ?? state.city,
            decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
            items: cities.map((city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(),
            onChanged: (city) {
              context.read<EditProfileBloc>().add(CityChanged(city: city));
              setState(() => selectedCity = city);
            },
          ));
    });
  }

  Widget _homeTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      String? selectedHomeTown;
      return ListTile(
          tileColor: Colors.white,
          leading: const Icon(Icons.home),
          title: TextFormField(
            initialValue: state.homeTown,
            decoration: const InputDecoration.collapsed(hintText: "Where are you from?"),
            // value: selectedHomeTown ?? state.homeTown,
            // decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
            // items: cities.map((city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(),
            onChanged: (value) {
              context.read<EditProfileBloc>().add(HomeTownChanged(homeTown: value));
              setState(() => selectedHomeTown = value);
            },
          ));
    });
  }

  // TODO: how should neighbourhood & city work?
  // its possible to use one map selector and strooe one value, latlong, and then from that get neighbourhood and city
  // however, this seems like a complex solution, maybe there is a simpler one?

  // Widget _locationTile() {
  //   return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
  //     String? selectedNeighbourhood;
  //     return ListTile(
  //         tileColor: Colors.white,
  //         leading: const Icon(Icons.location_on),
  //         title: DropdownButtonFormField<String>(
  //           menuMaxHeight: MediaQuery.of(context).size.height / 4,
  //           iconSize: 0.0,
  //           hint: const Text("Where do you live?"),
  //           value: selectedCity ?? state.city,
  //           decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
  //           items: cities.map((city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(),
  //           onChanged: (city) {
  //             context.read<EditProfileBloc>().add(CityChanged(city: city));
  //             setState(() => selectedCity = city);
  //           },
  //         ));
  //   });
  // }

  Widget _genderTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      String? selectedGender;
      return ListTile(
        tileColor: Colors.white,
        leading: const Icon(Icons.transgender),
        title: DropdownButtonFormField<String>(
          menuMaxHeight: MediaQuery.of(context).size.height / 4,
          iconSize: 0.0,
          hint: const Text("Select a gender"),
          value: selectedGender ?? state.gender,
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
          items: genders.map((gender) => DropdownMenuItem<String>(value: gender, child: Text(gender))).toList(),
          onChanged: (gender) {
            context.read<EditProfileBloc>().add(GenderChanged(gender: gender));
            setState(() => selectedGender = gender);
          },
        ),
      );
    });
  }

  Widget _interestedInTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      String? selectedInterestedIn;
      return ListTile(
        tileColor: Colors.white,
        leading: const Icon(Icons.celebration), //Icons.all_inclusive //Icons.people //
        title: DropdownButtonFormField<String>(
          menuMaxHeight: MediaQuery.of(context).size.height / 4,
          iconSize: 0.0,
          hint: const Text("Who do you want to meet?"),
          value: selectedInterestedIn ?? state.interestedIn,
          decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
          items: interstedInList.map((interestedIn) => DropdownMenuItem<String>(value: interestedIn, child: Text(interestedIn))).toList(),
          onChanged: (interestedIn) {
            context.read<EditProfileBloc>().add(InterestedInChanged(interestedIn: interestedIn));
            setState(() => selectedInterestedIn = interestedIn);
          },
        ),
      );
    });
  }

  Widget _birthdayTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      TextEditingController dateCtl = TextEditingController();
      DateFormat dateFormat = DateFormat("dd MMM yyyy");
      if (state.birthday != null) {
        dateCtl.text = dateFormat.format(state.birthday!);
      }
      return ListTile(
          tileColor: Colors.white,
          leading: const Icon(Icons.cake),
          title: TextFormField(
            controller: dateCtl,
            decoration: const InputDecoration(hintText: "Select your date of birth", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
            onTap: () async {
              DateTime? date = DateTime(1900);
              FocusScope.of(context).requestFocus(FocusNode());

              date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));

              if (date != null) {
                context.read<EditProfileBloc>().add(
                      BirthdayChanged(birthday: date),
                    );
              }
            },
          ));
    });
  }

  Widget _descriptionTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return ListTile(
        tileColor: Colors.white,
        leading: const Icon(Icons.edit),
        title: TextFormField(
          initialValue: state.userDescription,
          decoration: const InputDecoration.collapsed(hintText: 'Say something about yourself'),
          maxLines: null,
          onChanged: (value) => context.read<EditProfileBloc>().add(ProfileDescriptionChanged(description: value)),
        ),
      );
    });
  }

  Widget _jobTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return ListTile(
          tileColor: Colors.white,
          leading: const Icon(Icons.work),
          title: TextFormField(
            initialValue: state.occupation,
            decoration: const InputDecoration.collapsed(hintText: 'Position, Company'),
            maxLines: null,
            onChanged: (value) => context.read<EditProfileBloc>().add(OccupationChanged(occupation: value)),
          ));
    });
  }

  Widget _educationTile() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return ListTile(
          tileColor: Colors.white,
          leading: const Icon(Icons.school),
          title: TextFormField(
            initialValue: state.university,
            decoration: const InputDecoration.collapsed(hintText: 'University'),
            maxLines: null,
            onChanged: (value) => context.read<EditProfileBloc>().add(UniversityChanged(university: value)),
          ));
    });
  }

  Widget _editProfileRow() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _saveProfileChangesButton(),
          const SizedBox(
            width: 5,
          ),
          _changeProfilePictureButton()
        ],
      );
    });
  }

  Widget _saveProfileChangesButton() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return (state.formStatus is FormSubmitting)
          ? const CircularProgressIndicator()
          : ElevatedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(const BorderSide(width: 3)),
              ),
              onPressed: () async {
                context.read<EditProfileBloc>().add(SaveProfileChanges());
              },
              child: const Text('Save Changes'),
            );
    });
  }

  Widget _changeProfilePictureButton() {
    return BlocBuilder<EditProfileBloc, EditProfileState>(builder: (context, state) {
      return TextButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(const BorderSide(width: 3, color: Colors.black)),
        ),
        onPressed: () => context.read<EditProfileBloc>().add(ChangeAvatarRequest()),
        child: const Text('Change Picture'),
      );
    });
  }

  void _showImageSourceActionSheet(BuildContext context) {
    void _selectImageSource(ImageSource imageSource) {
      context.read<EditProfileBloc>().add(OpenImagePicker(imageSource: imageSource));
    }

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () {
                Navigator.pop(context);
                _selectImageSource(ImageSource.camera);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Gallery'),
              onPressed: () {
                Navigator.pop(context);
                _selectImageSource(ImageSource.gallery);
              },
            )
          ],
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              _selectImageSource(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              _selectImageSource(ImageSource.gallery);
            },
          ),
        ]),
      );
    }
  }
}
