import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/image_source_sheet.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/loading_state.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/storage_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/button_dialog.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/group_card.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/user_image_small.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/add_third_screen.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_state.dart';
import 'package:white_ui_supabase4/pages/authenticated/meet/meet_bloc.dart';

class CrewRequestScreen extends StatefulWidget {
  const CrewRequestScreen({Key? key, required this.friends, required this.meetBloc, required this.storageRepo}) : super(key: key);

  final Map<dynamic, Profile?>? friends;
  final MeetBloc meetBloc;
  final StorageRepository storageRepo;
  @override
  State<CrewRequestScreen> createState() => _CrewRequestScreenState();
}

class _CrewRequestScreenState extends State<CrewRequestScreen> {
  final picker = ImagePicker();
  bool _photoSelected = false;
  LoadingState loadingState = const Loaded();
  XFile? imageXFile;
  File? imageFile;

  Future<String?> uploadFile() async {
    String? imageURL = await widget.storageRepo.uploadGroupPhoto(imageXFile!);
    return imageURL;
  }

  @override
  Widget build(BuildContext context) {
    final friends = widget.friends;
    final meetBloc = widget.meetBloc;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<CrewRequestBloc>(),
        ),
        BlocProvider.value(
          value: meetBloc,
        )
      ],
      child: BlocListener<CrewRequestBloc, CrewRequestState>(
          listener: (context, state) {},
          child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
                return SingleChildScrollView(
                    child: SafeArea(
                        child: Container(
                            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - (AppBar().preferredSize.height + MediaQuery.of(context).viewPadding.top)),
                            // height: MediaQuery.of(context).size.height - (AppBar().preferredSize.height + MediaQuery.of(context).viewPadding.top),
                            // width: MediaQuery.of(context).size.width,
                            child: state.crew != null
                                ? Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                                    _crew(),
                                  ])
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      _crewRequests(),
                                      _friends(friends!.values.toList()),
                                    ],
                                  ))));
              }))),
    );
  }

  Widget _crew() {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      return loadingState is Loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(children: [
              SizedBox(
                height: MediaQuery.of(context).size.width * (1.5),
                width: MediaQuery.of(context).size.width,
                child: Center(child: GroupCard(crew: state.crew!)),
              ),
              const SizedBox(height: 40),
              _editCrewRow(),
            ]);
    });
  }

  Widget _editCrewRow() {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _addCrewPhotoButton(),
          const SizedBox(
            width: 5,
          ),
          _removeCrewButton()
        ],
      );
    });
  }

  Widget _addCrewPhotoButton() {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      void onSuccess(XFile pickedImage) async {
        setState(() {
          imageFile = File(pickedImage.path);
          imageXFile = pickedImage;
          _photoSelected = true;
        });
        if (_photoSelected) {
          String? imageUrl = await uploadFile();
          context.read<CrewRequestBloc>().add(AddCrewPhoto(crew: state.crew!, url: imageUrl!));
        }
      }

      return ElevatedButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(const BorderSide(width: 3)),
        ),
        onPressed: () async {
          showImageSourceActionSheet(context, picker, onSuccess);
        },
        child: const Text('Add Crew Photo'),
      );
    });
  }

  Widget _removeCrewButton() {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      return TextButton(
        style: ButtonStyle(
          side: MaterialStateProperty.all(const BorderSide(width: 3, color: Colors.black)),
        ),
        onPressed: () => context.read<CrewRequestBloc>().add(RemoveCrew(crew: state.crew!)),
        child: const Text('Remove Crew'),
      );
    });
  }

  Widget _crewRequests() {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      final sentCrewRequests = state.sentCrewRequests;
      final receivedCrewRequests = state.receivedCrewRequests;
      var requestsLength = (sentCrewRequests != null)
          ? (receivedCrewRequests != null)
              ? sentCrewRequests.length + receivedCrewRequests.length
              : sentCrewRequests.length
          : (receivedCrewRequests != null)
              ? receivedCrewRequests.length
              : 0;
      String headingText = "Requests (" + requestsLength.toString() + ")";
      return loadingState is Loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                maintainState: true,
                title: Text(
                  headingText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                children: [
                  if (receivedCrewRequests != null && receivedCrewRequests.isNotEmpty)
                    ListView.separated(
                        separatorBuilder: (context, index) {
                          return Container(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.transparent, width: 10)),
                            ),
                          );
                        },
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.receivedCrewRequests!.length,
                        itemBuilder: (BuildContext context, int index) {
                          CrewRequest request = receivedCrewRequests.values.elementAt(index);
                          Profile userProfile = request.friend!;
                          return (request.relatedRequest?.status != null && request.relatedRequest?.status == "crew")
                              ?
                              // SizedBox(
                              //     height: MediaQuery.of(context).size.width * 0.3,
                              //     width: MediaQuery.of(context).size.width * 0.3,
                              //     child:
                              ListTile(
                                  dense: true,
                                  // shape: Border(
                                  //     // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                                  //     // bottom: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
                                  //     // top: BorderSide(color: Colors.black.withOpacity(0.5), width: 1),
                                  //     ),
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              UserImageSmall(
                                                url: userProfile.avatarUrl!,
                                                height: 90,
                                                width: 90,
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                child: Text(userProfile.name!.split(" ").first, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              UserImageSmall(
                                                url: request.relatedRequest!.friend!.avatarUrl!,
                                                height: 90,
                                                width: 90,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                                child: Text(request.relatedRequest!.friend!.name!.split(" ").first, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => context.read<CrewRequestBloc>().add(ConfirmCrewRequest(request: request, friend: userProfile)),
                                            child: Container(
                                              height: 90,
                                              width: 90,
                                              decoration:
                                                  BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(8.0), border: Border.all(color: Colors.black.withOpacity(0.5), width: 1)),
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Icon(Icons.celebration),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text("Join them!"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : ListTile(
                                  shape: const Border(
                                    // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                                    bottom: BorderSide(color: Colors.transparent, width: 10),
                                  ),
                                  leading: avatar(userProfile.avatarUrl!),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [_confirmButton(request, userProfile), const SizedBox(width: 5), _deleteButton(request)]),
                                  title: Text(userProfile.name!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  subtitle: (request.relatedRequest != null)
                                      ? Text(
                                          "& " + request.relatedRequest!.friend!.name!,
                                          style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                );
                        }),
                  if (sentCrewRequests != null && sentCrewRequests.isNotEmpty)
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.sentCrewRequests!.length,
                        itemBuilder: (BuildContext context, int index) {
                          CrewRequest request = sentCrewRequests.values.elementAt(index);
                          Profile userProfile = request.friend!;

                          return ListTile(
                            shape: const Border(
                              // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                              bottom: BorderSide(color: Colors.transparent, width: 10),
                            ),
                            leading: avatar(userProfile.avatarUrl!),
                            trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (request.relatedRequest == null) _addAnotherButton(request), const SizedBox(width: 5), _deleteButton(request)]),
                            title: Text(userProfile.name!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: (request.relatedRequest != null)
                                ? Text(
                                    "& " + request.relatedRequest!.friend!.name!,
                                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          );
                        }),
                  if ((receivedCrewRequests == null || receivedCrewRequests.isEmpty) && (sentCrewRequests == null || sentCrewRequests.isEmpty))
                    const Padding(
                      padding: EdgeInsets.all(60.0),
                      child: Text(
                        "No requests just yet! Send some!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  // if (state.sentCrewRequests!.isNotEmpty || state.receivedCrewRequests!.isNotEmpty)
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ));
    });
  }

  Widget _friends(List<Profile?>? friends) {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      var friends = state.friends?.values.toList();
      String headingText = "Send Invites";

      return loadingState is Loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                maintainState: true,
                title: Text(
                  headingText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                children: [
                  if (friends != null && friends.isNotEmpty)
                    ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: friends.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                              shape: const Border(
                                // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                                bottom: BorderSide(color: Colors.transparent, width: 10),
                              ),
                              leading: avatar(friends[index].avatarUrl!),
                              trailing: _sendCrewRequestButton(friends[index]),
                              title: Text(friends[index].name!));
                        }),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ));
    });
  }

  Widget _sendCrewRequestButton(Profile friend) {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      void onSendCrewConfirmed() => context.read<CrewRequestBloc>().add(SendCrewRequest(friend: friend));
      final buttonContent = Text.rich(TextSpan(
          text: "Head out with ", children: <TextSpan>[TextSpan(text: friend.name!, style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)), const TextSpan(text: "?")]));
      const subContent = Text("You can add a 3rd once it's sent!");

      return loadingState is Loading
          ? Container()
          : ElevatedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(const BorderSide(width: 1)),
              ),
              onPressed: () {
                showButtonDialog(context, "Create crew", buttonContent,
                    icon: const Icon(
                      Icons.group_add,
                      color: Colors.black,
                    ),
                    subContent: subContent,
                    onConfirmed: onSendCrewConfirmed);
              },
              child: const Icon(Icons.group_add),
            );
    });
  }

  Widget _addAnotherButton(CrewRequest request) {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      // void onSendCrewConfirmed() => context.read<CrewRequestBloc>().add(SendCrewRequest(user: state.user, friend: friend));
      return loadingState is Loading
          ? Container()
          : ElevatedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(const BorderSide(width: 1)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddThirdScreen(request: request, crewBloc: context.read<CrewRequestBloc>())));
              },
              child: const Text("Add a 3rd"),
            );
      // : Row(
      //     mainAxisSize: MainAxisSize.min,
      //     children: [
      //       Text(
      //         "& " + request.thirdUserName!,
      //         style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      //       ),
      //       const SizedBox(
      //         width: 25,
      //       )
      //     ],
      //   );
    });
  }

  Widget _confirmButton(CrewRequest request, Profile friend) {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      return loadingState is Loading
          ? Container()
          : ElevatedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(const BorderSide(width: 1)),
              ),
              onPressed: () {
                context.read<CrewRequestBloc>().add(ConfirmCrewRequest(request: request, friend: friend));
              },
              child: const Text("Let's go!"),
            );
    });
  }

  Widget _deleteButton(CrewRequest request) {
    return BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
      final loadingState = state.loadingState;
      return loadingState is Loading
          ? Container()
          : TextButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(const BorderSide(width: 1, color: Colors.black)),
              ),
              onPressed: () {
                context.read<CrewRequestBloc>().add(DeleteCrewRequest(request: request));
              },
              child: const Text(
                "Delete",
              ),
            );
    });
  }

  // void _removeCrew(BuildContext context, Profile user, String friendId, bool sender) async {
  //   String userId = user.id!;
  //   context.read<MeetBloc>().add(RemoveCrew(userId: userId, friendId: friendId));
  // }

  // void showConfirmationDialog(BuildContext context, String title, String text, Profile user, Profile friend, bool send) {
  //   // set up the buttons
  //   Widget cancelButton = TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(context, rootNavigator: true).pop('dialog'));
  //   Widget continueButton = ElevatedButton(
  //       child: const Text("Continue"),
  //       onPressed: () {
  //         if (send) {
  //           _sendCrewRequest(context, user, friend);
  //         } else {
  //           _confirmCrewRequest(context, user, friend.id!);
  //           // context.read<MeetBloc>().add(OverwritePreviousMeets(userId: user.id, friendId: friend.id!));
  //         }
  //         Navigator.of(context, rootNavigator: true).pop('dialog');
  //       });
  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text(title),
  //     content: Text(text),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );
  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }
}
