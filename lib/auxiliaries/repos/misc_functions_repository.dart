import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

final supabase = Supabase.instance.client;

Future<Profile?> getUserById(String userId, {bool? withFriends}) async {
  Profile? user;
  String query;
  try {
    if (withFriends != null && withFriends == true) {
      query =
          '*, friends:friendships!friendships_user_id_fkey(*, friend:profiles!friendships_friend_id_fkey(*, friends:friendships!friendships_user_id_fkey(*, friend:profiles!friendships_friend_id_fkey(*))))';
    } else {
      query = '*';
    }

    final data = await supabase.from('profiles').select(query).eq('id', userId);
    if (data.isNotEmpty) {
      user = Profile.fromJson(data.first);
    }
  } catch (e) {
    rethrow;
  }
  return user;
}

Future<Profile?> getUsersFriendsAndCrewAndMatchesAndLikesFromId(String userId) async {
  try {
    String query = '*,'
        // get likes user has sent, and the assoc. other cerw and profiles
        'sentLikes:likes!likes_user_id_fkey(*,'
        'crew!likes_other_crew_id_fkey(*, '
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*))),'
        // get users match history
        'matchConfirmations:match_confirmations!match_confirmations_user_id_fkey(*,'
        'match:matches!match_confirmations_match_id_fkey(*,'
        'crewOne:crew!matches_crew_id_one_fkey(*,'
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        '),'
        'crewTwo:crew!matches_crew_id_two_fkey(*,'
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        '),'
        'venue:venues!matches_venue_id_fkey(*)'
        ')'
        '),'
        // get crew where user match userIdOne
        // get crews users
        'crewOne:crew!crew_user_id_one_fkey(*,'
        // get ownCrews users
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        '),'
        // get crew where user match userIdTwo
        // get crews users
        'crewTwo:crew!crew_user_id_two_fkey(*,'
        // get ownCrews users
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        '),'
        // get crew where user match userIdThree
        // get crews users
        'crewThree:crew!crew_user_id_three_fkey(*,'
        // get ownCrews users
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        '),'
        // get user friendships, associated profile & their friends (list of profiles)
        'friends:friendships!friendships_user_id_fkey(*,'
        'friend:profiles!friendships_friend_id_fkey(*,'
        'friends:friendships!friendships_user_id_fkey(*,'
        'friend:profiles!friendships_friend_id_fkey(*'
        ')'
        ')'
        ')'
        ')';

    final data = await supabase.from('profiles').select(query).eq('id', userId).single() as Map;

    Profile? userProfile;
    if (data.isNotEmpty) {
      userProfile = Profile.fromJson(data);
    }
    return userProfile;
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  }
}

Future<Crew?> getProfilesForCrew(crew) async {
  try {
    Crew? crewWithProfiles;
    String query = '*,'
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        ')';

    final data = await supabase.from('crew').select(query).eq('id', crew.id).single() as Map;
    if (data.isNotEmpty) {
      crew = Crew.fromJson(data);
    }
    return crewWithProfiles;
  } catch (e) {
    debugPrint(e.toString());
    rethrow;
  }
}

Future<Map?> separateBuzzUsersAndContacts({List<fc.Contact>? contacts, Map<dynamic, dynamic>? contactsMap, bool? getBuzzUsersFriends}) async {
  Map? output;
  String query;
  if (getBuzzUsersFriends != null && getBuzzUsersFriends) {
    query =
        '*, friends:friendships!friendships_user_id_fkey(*, friend:profiles!friendships_friend_id_fkey(*, friends:friendships!friendships_user_id_fkey(*, friend:profiles!friendships_friend_id_fkey(*))))';
  } else {
    query = '*';
  }
  List<dynamic> phoneNumbers = [];
  Map<dynamic, Profile> buzzUsers = {};
  List<fc.Contact> otherContacts = [];
  Map<dynamic, dynamic> otherContactsMap = {};

  if (contacts != null && contacts.isNotEmpty) {
    for (var contact in contacts) {
      final fullContact = await fc.FlutterContacts.getContact(contact.id);
      if (fullContact != null) {
        List<dynamic> phones = fullContact.phones;
        if (phones.isNotEmpty) {
          otherContacts.add(fullContact);
          phoneNumbers.add(phones.first.number);
        }
      }
    }
  } else if (contactsMap != null && contactsMap.isNotEmpty) {
    phoneNumbers.addAll(contactsMap.values);
  }

  phoneNumbers = standardisePhoneNumbers(phoneNumbers);
  final fullPhoneData = await supabase.from('profiles').select(query).in_('phone', phoneNumbers);
  final localPhoneData = await supabase.from('profiles').select(query).in_('local_number', phoneNumbers);
  final userData = fullPhoneData + localPhoneData;
  if (userData.isNotEmpty) {
    for (var elem in userData) {
      if (elem['phone'] != null) {
        phoneNumbers.remove(elem['phone']);
      }
      if (elem['local_number'] != null) {
        phoneNumbers.remove(elem['local_number']);
      }
      Profile user = Profile.fromJson(elem);
      buzzUsers[user.id] = user;
    }
  }

  if (otherContacts.isNotEmpty) {
    otherContacts.retainWhere((element) {
      if (element.phones.isNotEmpty) {
        return phoneNumbers.contains(standardisePhoneNumbers([element.phones.first.number]).first);
      } else {
        return false;
      }
    });
  } else if (contactsMap != null && contactsMap.isNotEmpty) {
    otherContactsMap = contactsMap;
    otherContactsMap.removeWhere((key, value) => !(phoneNumbers.contains(standardisePhoneNumbers([value]).first)));
  }

  output = {
    "buzzUsers": buzzUsers,
    "otherContacts": otherContacts.isNotEmpty ? otherContacts : otherContactsMap,
  };

  return output;
}

List<String> standardisePhoneNumbers(List<dynamic> phoneNumbers) {
  // Far from perfect, but will do for now in terms of searching db for phone numbers
  // Should only return users once, as will only have one number, either full (with country code) or partial number...
  // ...for each, I think?
  List<String> standardisedOutput = [];
  for (var element in phoneNumbers) {
    element = element.replaceAll(" ", "");
    element = element.replaceAll("(", "");
    element = element.replaceAll(")", "");
    element = element.replaceAll("-", "");
    if (element.startsWith("00")) {
      element = element.replaceFirst("00", "+");
    } else if (element.startsWith("0")) {
      element = element.replaceFirst("0", "");
    }
    standardisedOutput.add(element);
  }
  return standardisedOutput;
}
