import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/additional_screens/crew/crew_request_state.dart';

class AddThirdScreen extends StatefulWidget {
  // final String title;
  final CrewRequest request;
  final CrewRequestBloc crewBloc;

  const AddThirdScreen({Key? key, required this.request, required this.crewBloc}) : super(key: key);

  @override
  State<AddThirdScreen> createState() => _AddThirdScreenState();
}

class _AddThirdScreenState extends State<AddThirdScreen> {
  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return BlocProvider.value(
      value: widget.crewBloc,
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Add to crew with " + request.friend!.name!),
          ),
          body: BlocBuilder<CrewRequestBloc, CrewRequestState>(builder: (context, state) {
            return SingleChildScrollView(
                child: Container(
                    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(
                        height: 15,
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.friends!.length,
                          itemBuilder: (BuildContext context, int index) {
                            // CrewRequest request = sentCrewRequests.values.elementAt(index);
                            Profile? userProfile = state.friends!.values.elementAt(index);
                            return ListTile(
                                shape: const Border(
                                  // WORKS LIKE A SIZED BOX, bit ratchet, should use Listvew.separated
                                  bottom: BorderSide(color: Colors.transparent, width: 10),
                                ),
                                leading: avatar(userProfile.avatarUrl!),
                                trailing: ElevatedButton(
                                  child: const Text("Add to crew"),
                                  onPressed: () {
                                    context.read<CrewRequestBloc>().add(AddThirdToCrewRequest(request: request, friend: userProfile));
                                    Navigator.pop(context);
                                  },
                                ),
                                title: Text(userProfile.name!));
                          }),
                    ])));
          })),
    );
  }
}
