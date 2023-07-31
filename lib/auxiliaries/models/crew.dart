// ignore_for_file: non_constant_identifier_names

import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';

class Crew {
  String? id;
  String? createdAt;
  String? userIdOne;
  String? userIdTwo;
  String? userIdThree;
  Map<dynamic, Profile>? users;
  Map<dynamic, Profile>? usersMutualFriends;
  Map<dynamic, Match>? previousMatchesTogether;
  Map<dynamic, MatchConfirmation>? pendingMatchConfirmations;
  String? groupPhotoUrl;
  String? date;
  String? status;
  String? type;
  String? interestedIn;
  String? city;
  Map<dynamic, Profile>? receivedLikes;

  Crew({
    this.id,
    this.userIdOne,
    this.userIdTwo,
    this.userIdThree,
    this.users,
    this.usersMutualFriends,
    this.previousMatchesTogether,
    this.pendingMatchConfirmations,
    this.date,
    this.status,
    this.type,
    this.interestedIn,
    this.city,
    this.groupPhotoUrl,
    this.createdAt,
    this.receivedLikes,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'user_id_one': userIdOne,
        'user_id_two': userIdTwo,
        'user_id_three': userIdThree,
        'date': date,
        'status': status,
        'group_photo_url': groupPhotoUrl,
        'created_at': createdAt,
      };

  static Crew fromJson(Map<dynamic, dynamic>? json) {
    Profile? userOne;
    Profile? userTwo;
    Profile? userThree;
    Map<dynamic, Profile> users = {};
    Map<dynamic, Profile> usersMutualFriends = {};
    Map<dynamic, Match> previousMatchesTogether = {};
    Map<dynamic, Profile> receivedLikes = {};
    Map<dynamic, MatchConfirmation> pendingMatchConfirmations = {};
    if (json!['userOne'] != null && json['userOne'].isNotEmpty) {
      userOne = Profile.fromJson(json['userOne']);
      users[userOne.id!] = userOne;
    }
    if (json['userTwo'] != null && json['userTwo'].isNotEmpty) {
      userTwo = Profile.fromJson(json['userTwo']);
      users[userTwo.id!] = userTwo;
    }
    if (json['userThree'] != null && json['userThree'].isNotEmpty) {
      userThree = Profile.fromJson(json['userThree']);
      users[userThree.id!] = userThree;
    }
    if (json['receivedLikes'] != null && json['receivedLikes'].isNotEmpty) {
      for (var like in json['receivedLikes']) {
        String id = like['user_id'];
        bool? liked = like['like'];
        if (liked ?? false) {
          Profile likeSender = Profile.fromJson(like['profiles']);
          receivedLikes[id] = likeSender;
        }
      }
    }
    if (json['matchConfirmations'] != null && json['matchConfirmations'].isNotEmpty) {
      for (var matchConfirmation in json['matchConfirmations']) {
        MatchConfirmation pendingMatchConfirmation = MatchConfirmation.fromJson(matchConfirmation);
        if (pendingMatchConfirmation.confirmed != null && pendingMatchConfirmation.confirmed!) {
          // Match? match = pendingMatchConfirmation.match;
          // if (match != null) {
          //   if (match.date == today) {
          //     currentMatch = match;
          //   } else {
          //     matchHistory[pendingMatchConfirmation.otherCrewId] = match;
          //   }
          // }
        }
        pendingMatchConfirmations[pendingMatchConfirmation.otherCrewId] = pendingMatchConfirmation;
      }
    }
    if (json['matchOne'] != null && json['matchOne'].isNotEmpty) {}
    if (json['matchTwo'] != null && json['matchTwo'].isNotEmpty) {}
    if (users.isNotEmpty) {
      usersMutualFriends = getCrewUsersMutualFriends(users: users);
      previousMatchesTogether = getCrewPreviousMatchesTogether(users: users);
    }
    return Crew(
      id: json['id'] as String?,
      userIdOne: json['user_id_one'] as String?,
      userIdTwo: json['user_id_two'] as String?,
      userIdThree: json['user_id_three'] as String?,
      users: users,
      usersMutualFriends: usersMutualFriends,
      previousMatchesTogether: previousMatchesTogether,
      pendingMatchConfirmations: pendingMatchConfirmations,
      date: json['date'] as String?,
      status: json['status'] as String?,
      type: json['type'] as String?,
      interestedIn: json['interested_in'] as String?,
      city: json['city'] as String?,
      groupPhotoUrl: json['group_photo_url'] as String?,
      createdAt: json['created_at'] as String?, //DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      receivedLikes: receivedLikes,
    );
  }
}
