import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/friends_repository.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/avatar.dart';
import 'package:white_ui_supabase4/auxiliaries/widgets/continue_button.dart';
import 'package:white_ui_supabase4/pages/onboarding/onboarding_cubit.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';
import 'package:hive/hive.dart';

class ContactsScreen extends StatefulWidget {
  final FriendsRepository friendsRepo;
  const ContactsScreen({Key? key, required this.friendsRepo}) : super(key: key);

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String userId = supabase.auth.currentUser!.id;

  List<Contact>? _contacts;
  List<Profile>? _buzzUsers;
  List<Contact>? _otherContacts;
  List<bool>? _selectedBuzzUsers;
  List<bool>? _selectedOtherContacts;
  bool _permissionDenied = false;
  bool get areSomeUsersSelected => _selectedBuzzUsers!.any((element) => element);
  bool get areSomeContactsSelected => _selectedOtherContacts!.any((element) => element);

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future _fetchContacts() async {
    var contactsPermission = await Hive.openBox('contacts_permission');
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() => _permissionDenied = true);
      contactsPermission.put('permission', false);
    } else {
      final contacts = await FlutterContacts.getContacts();
      contactsPermission.put('permission', true);
      final reorderedContacts = await separateBuzzUsersAndContacts(contacts: contacts);
      setState(() {
        _contacts = contacts;
        _buzzUsers = reorderedContacts!['buzzUsers'].values.toList();
        _selectedBuzzUsers = List.filled(_buzzUsers!.length, false, growable: true);
        _otherContacts = reorderedContacts['otherContacts'];
        _selectedOtherContacts = List.filled(_otherContacts!.length, false, growable: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Contacts'),
          actions: [
            TextButton(
              child: const Text("Skip", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
              onPressed: () async {
                var contactBox = await Hive.openBox('contacts');
                Map<dynamic, dynamic> contactsMap = await convertContactsToMap(_contacts!);
                await contactBox.putAll(contactsMap);
                context.read<OnboardingCubit>().showProfilePhoto();
              },
            ),
          ],
        ),
        body: _body());
  }

  Widget _body() {
    if (_permissionDenied) return const Center(child: Text('Permission denied'));
    if (_contacts == null) return const Center(child: CircularProgressIndicator());
    return Stack(children: [
      SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buzzUsersWidget(),
            const SizedBox(
              height: 10,
            ),
            _inviteContactsWidget(),
          ],
        ),
      ])),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4, bottom: 0.0),
          child: SizedBox(
              width: double.infinity,
              child: Container(
                  height: 100,
                  // color: Colors.white70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white70,
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 45.0, left: 10.0, right: 10.0, top: 0.0),
                    child: continueButton(onContinuePressed, enableButton: (areSomeUsersSelected | areSomeContactsSelected)),
                  ))),
        ),
      ),
    ]);
  }

  Widget _buzzUsersWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.5)))),
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10.0),
              child: Row(
                children: const [
                  Text(
                    "Contacts using Buzz",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
        Container(
          child: _buzzUsers!.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _buzzUsers!.length,
                  itemBuilder: (context, index) {
                    // _selectedBuzzUsers = List.filled(_buzzUsers!.length, false, growable: true);
                    final userProfile = _buzzUsers![index];
                    final countryCode = userProfile.countryCode;
                    final localNumber = userProfile.localNumber;
                    String? combinedNumber;
                    if (countryCode != null && localNumber != null) {
                      combinedNumber = countryCode + localNumber;
                    } else if (localNumber != null) {
                      combinedNumber = "0" + localNumber;
                    }
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 15.0, right: 0.0),
                      leading: avatar(userProfile.avatarUrl),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _addButton(userProfile, index),
                          const SizedBox(width: 5),
                          _removeButton(index, profile: userProfile),
                        ],
                      ),
                      title: Text(
                        userProfile.name ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        userProfile.phone ?? combinedNumber ?? "",
                      ),
                    );
                  })
              : SizedBox(
                  height: 100,
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1, color: Colors.black.withOpacity(0.1)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(7.0),
                          child: Text(
                            "None of your contacts seem to be using Buzz yet, invite some!",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _inviteContactsWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black.withOpacity(0.5)))),
          height: 60,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 10.0),
            child: Row(children: const [
              Text(
                "Invite your contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ]),
          ),
        ),
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _otherContacts!.length,
            itemBuilder: (context, i) => ListTile(
                contentPadding: const EdgeInsets.only(left: 15.0, right: 0.0),
                leading: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    width: 50,
                    height: 50,
                    child: ClipRRect(borderRadius: BorderRadius.circular(25), child: const Icon(Icons.person))),
                title: Text(_otherContacts![i].displayName),
                subtitle: Text(_otherContacts![i].phones.first.number.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inviteButton(_otherContacts![i], i),
                    const SizedBox(width: 10),
                    _removeButton(i, contact: _otherContacts![i]),
                  ],
                ),
                onTap: () async {
                  final fullContact = await FlutterContacts.getContact(_otherContacts![i].id);
                  debugPrint(fullContact.toString());
                  // await Navigator.of(context).push(
                  //     MaterialPageRoute(builder: (_) => ContactPage(fullContact!)));
                })),
        // ),
      ],
    );
  }

  Widget _addButton(Profile friend, int index) {
    // bool selected = _selectedBuzzUsers![index];
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(_selectedBuzzUsers![index] ? Colors.white : Colors.black)),
      onPressed: () {
        setState(() {
          _selectedBuzzUsers![index] = !_selectedBuzzUsers![index];
        });
        // _addFriend(context, state.user, friend);
      },
      child: _selectedBuzzUsers![index]
          ? const Icon(
              Icons.done,
              color: Colors.black,
            )
          : const Icon(Icons.add),
    );
  }

  Widget _inviteButton(Contact contact, int index) {
    return ElevatedButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(_selectedOtherContacts![index] ? Colors.white : Colors.black)),
      onPressed: () {
        setState(() {
          _selectedOtherContacts![index] = !_selectedOtherContacts![index];
        });
        // _addFriend(context, state.user, friend);
      },
      child: _selectedOtherContacts![index]
          ? const Icon(
              Icons.done,
              color: Colors.black,
            )
          : const Text("Invite"),
    );
  }

  Widget _removeButton(int index, {Profile? profile, Contact? contact}) {
    return IconButton(
      iconSize: 20,
      icon: const Icon(Icons.clear),
      onPressed: () {
        setState(() {
          if (profile != null) {
            _buzzUsers!.removeAt(index);
            _selectedBuzzUsers!.removeAt(index);
          } else if (contact != null) {
            _otherContacts!.removeAt(index);
            _selectedOtherContacts!.removeAt(index);
          }
        });
        // _addFriend(context, state.user, friend);
      },
    );
  }

  void onContinuePressed() async {
    final friendsRepo = widget.friendsRepo;
    if (areSomeUsersSelected) {
      _buzzUsers!.retainWhere((element) => _selectedBuzzUsers![_buzzUsers!.indexOf(element)]);
      Map<dynamic, Profile> sentRequests = {};
      for (var friend in _buzzUsers!) {
        friendsRepo.sendFriendRequest(friend.id!);
        sentRequests[friend.id] = friend;
      }
    }

    if (areSomeContactsSelected) {
      _otherContacts!.retainWhere((element) => _selectedOtherContacts![_otherContacts!.indexOf(element)]);
      for (var contact in _otherContacts!) {
        debugPrint(contact.toString());
        // friendsRepo.sendInvite(contact);
      }
    }

    var contactBox = await Hive.openBox('contacts');
    Map<dynamic, dynamic> contactsMap = await convertContactsToMap(_contacts!);
    await contactBox.putAll(contactsMap);
    context.read<OnboardingCubit>().showProfilePhoto();
  }
}
