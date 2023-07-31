import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/popups/snack_bar.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/states/form_submission_status.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_bloc.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_event.dart';
import 'package:white_ui_supabase4/pages/authenticated/friends/friends_state.dart';

class InviteContacts extends StatefulWidget {
  const InviteContacts({Key? key, required this.friendsBloc}) : super(key: key);

  final FriendsBloc friendsBloc;

  @override
  State<InviteContacts> createState() => _InviteContactsState();
}

class _InviteContactsState extends State<InviteContacts> {
  @override
  Widget build(BuildContext context) {
    final friendsBloc = widget.friendsBloc;
    return BlocProvider.value(
        value: friendsBloc,
        child: BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              final formStatus = state.formStatus;
              if (formStatus is SubmissionSuccess) {
                showSnackBar(context, "Invite sent");
                context.read<FriendsBloc>().add(FriendsResetFormStatus());
              }
              if (formStatus is SubmissionFailed) {
                showSnackBar(context, formStatus.exception.toString());
                context.read<FriendsBloc>().add(FriendsResetFormStatus());
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text("Invite Contacts"),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      _inviteContactsWidget(),
                    ],
                  ),
                ))));
  }

  Widget _inviteContactsWidget() {
    return BlocBuilder<FriendsBloc, FriendsState>(builder: (context, state) {
      final otherContacts = state.otherContacts;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: otherContacts!.length,
              itemBuilder: (context, index) {
                final name = otherContacts.keys.elementAt(index);
                final phoneNumber = otherContacts.values.elementAt(index);
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 15.0, right: 0.0),
                  leading: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      width: 50,
                      height: 50,
                      child: ClipRRect(borderRadius: BorderRadius.circular(25), child: const Icon(Icons.person))),
                  title: Text(name),
                  subtitle: Text(phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _inviteButton(name, phoneNumber),
                      const SizedBox(width: 10),
                    ],
                  ),
                );
              }),
          // ),
        ],
      );
    });
  }

  Widget _inviteButton(String name, String phoneNumber) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
      onPressed: () {
        context.read<FriendsBloc>().add(InviteContactToBuzz(name: name, phoneNumber: phoneNumber));
      },
      child: const Text("Invite"),
    );
  }
}
