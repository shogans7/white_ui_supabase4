import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/profile_tile.dart';
import 'package:white_ui_supabase4/pages/onboarding/onboarding_cubit.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final supabase = Supabase.instance.client;
  LoadingState loadingState = const Loaded();
  String? selectedCity;
  String? selectedGender;
  String? selectedInterestedIn;
  String? description;

  bool get detailsSelected => (selectedCity != null && selectedGender != null && selectedInterestedIn != null);

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Profile'),
          actions: [
            TextButton(
              child: const Text("Skip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
              onPressed: () {
                context.read<OnboardingCubit>().finishedOnboarding();
              },
            ),
          ],
        ),
        body: _body());
  }

  Widget _body() {
    double height = MediaQuery.of(context).size.height - 2 * AppBar().preferredSize.height;
    return SingleChildScrollView(
        child: SizedBox(
      height: height,
      child: Stack(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "Just a few more details, and you're up and running!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _cityTile(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _genderTile(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _interestedInTile(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _descriptionTile(),
            ),
            const SizedBox(height: 200),
            // _descriptionTile(),
          ]),
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
                        child: continueButton(onContinuePressed, loadingState: loadingState, enableButton: detailsSelected),
                      ))),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _cityTile() {
    return profileTile(
      leading: const Icon(Icons.location_city),
      title: DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 4,
        iconSize: 0.0,
        hint: const Text("Select a city"),
        value: selectedCity,
        decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
        items: cities.map((city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(),
        onChanged: (city) {
          setState(() => selectedCity = city);
        },
      ),
    );
  }

  Widget _genderTile() {
    return profileTile(
      leading: const Icon(Icons.transgender),
      title: DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 4,
        iconSize: 0.0,
        hint: const Text("Select your gender"),
        value: selectedGender,
        decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
        items: genders.map((gender) => DropdownMenuItem<String>(value: gender, child: Text(gender))).toList(),
        onChanged: (gender) {
          // context.read<ProfileBloc>().add(GenderChanged(gender: gender));
          setState(() => selectedGender = gender);
        },
      ),
    );
  }

  Widget _interestedInTile() {
    // String? selectedInterestedIn;
    return profileTile(
      leading: const Icon(Icons.celebration), //Icons.all_inclusive //Icons.people //
      title: DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 4,
        iconSize: 0.0,
        hint: const Text("Who do you want to meet?"),
        value: selectedInterestedIn,
        decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),
        items: interstedInList.map((interestedIn) => DropdownMenuItem<String>(value: interestedIn, child: Text(interestedIn))).toList(),
        onChanged: (interestedIn) {
          // context.read<ProfileBloc>().add(InterestedInChanged(interestedIn: interestedIn));
          setState(() => selectedInterestedIn = interestedIn);
        },
      ),
    );
  }

  Widget _descriptionTile() {
    return profileTile(
        leading: const Icon(Icons.edit),
        title: TextFormField(
            initialValue: description,
            decoration: const InputDecoration.collapsed(hintText: 'Say something about yourself'),
            maxLines: null,
            // readOnly: !state.isCurrentUser,
            toolbarOptions: const ToolbarOptions(
              copy: true,
              cut: true,
              paste: true,
              selectAll: true,
            ),
            onChanged: (value) => description == value));
  }

  void onContinuePressed() async {
    setState(() {
      loadingState = const Loading();
    });

    if (detailsSelected) {
      final userId = supabase.auth.currentUser!.id;
      final updates = {
        'id': userId,
        // 'bio': selectedUserDescription,
        'city': selectedCity,
        'gender': selectedGender,
        'interested_in': selectedInterestedIn,
        'updated_at': DateTime.now().toIso8601String(),
      };
      try {
        await supabase.from('profiles').upsert(updates);
        context.read<OnboardingCubit>().updateUserProfile(selectedCity!, selectedGender!, selectedInterestedIn!);
        // context.read<AppViewBloc>().add(AppViewUserUpdatedEvent(updates: updates));
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    }

    setState(() {
      loadingState = const Loaded();
    });
    context.read<OnboardingCubit>().finishedOnboarding();
  }
}
