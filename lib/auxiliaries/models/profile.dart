// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';

final DateFormat formatter = DateFormat('yyyy-MM-dd');
final today = formatter.format(DateTime.now());

class Profile {
  String? bio;
  String? name;
  String? city;
  String? homeTown;
  String? neighbourhood;
  String? gender;
  String? interestedIn;
  String? id;
  String? avatarUrl;
  DateTime? birthday;
  String? occupation;
  String? university;
  String? subscription;
  String? phone;
  String? countryCode;
  String? localNumber;
  Map<dynamic, Profile>? friends;
  Map<dynamic, FriendRequest>? sentFriendRequests;
  Map<dynamic, FriendRequest>? receivedFriendRequests;
  Map<dynamic, Profile>? buzzUsersInContacts;
  Map<dynamic, dynamic>? otherContacts;
  Crew? crew;
  Map<dynamic, CrewRequest>? sentCrewRequests;
  Map<dynamic, CrewRequest>? receivedCrewRequests;
  Map<dynamic, Like>? sentLikes;
  Map<dynamic, MatchConfirmation>? pendingMatchConfirmations;
  Match? currentMatch;
  Map<dynamic, Match>? matchHistory;
  String? createdAt;
  String? updatedAt;

  Profile({
    this.bio,
    this.name,
    this.city,
    this.homeTown,
    this.neighbourhood,
    this.gender,
    this.interestedIn,
    this.id,
    this.avatarUrl,
    this.birthday,
    this.occupation,
    this.university,
    this.subscription,
    this.phone,
    this.countryCode,
    this.localNumber,
    this.friends,
    this.sentFriendRequests,
    this.receivedFriendRequests,
    this.buzzUsersInContacts,
    this.otherContacts,
    this.crew,
    this.sentCrewRequests,
    this.receivedCrewRequests,
    this.sentLikes,
    this.pendingMatchConfirmations,
    this.currentMatch,
    this.matchHistory,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, Object?> toJson() => {
        'bio': bio,
        'full_name': name,
        'city': city,
        'gender': gender,
        'interested_in': interestedIn,
        'id': id,
        'avatar_url': avatarUrl,
        'birthday': birthday,
        'subscription': subscription,
      };

  static Profile fromJson(Map<dynamic, dynamic>? json) {
    String currentUserId = supabase.auth.currentUser!.id;
    Map<dynamic, Profile> friends = {};
    Map<dynamic, FriendRequest> sentFriendRequests = {};
    Map<dynamic, FriendRequest> receivedFriendRequests = {};
    Crew? crew;
    Map<dynamic, CrewRequest> sentCrewRequests = {};
    Map<dynamic, CrewRequest> receivedCrewRequests = {};
    Map<dynamic, Like> sentLikes = {};
    Map<dynamic, MatchConfirmation> pendingMatchConfirmations = {};
    Match? currentMatch;
    Map<dynamic, Match> matchHistory = {};
    if (json!['friends'] != null && json['friends'].isNotEmpty) {
      for (var friendship in json['friends']) {
        String id = friendship['friend_id'];
        Profile friend = Profile.fromJson(friendship['friend']);
        friends[id] = friend;
      }
    }
    if (json['sentFriendRequests'] != null && json['sentFriendRequests'].isNotEmpty) {
      for (var request in json['sentFriendRequests']) {
        FriendRequest friendRequest = FriendRequest.fromJson(request);
        if (friendRequest.status == 'request') {
          String id = request['receiver_id'];
          sentFriendRequests[id] = friendRequest;
        }
      }
    }
    if (json['receivedFriendRequests'] != null && json['receivedFriendRequests'].isNotEmpty) {
      for (var request in json['receivedFriendRequests']) {
        FriendRequest friendRequest = FriendRequest.fromJson(request);
        if (friendRequest.status == 'request') {
          String id = request['sender_id'];
          receivedFriendRequests[id] = friendRequest;
        }
      }
    }
    if (json['crewOne'] != null && json['crewOne'].isNotEmpty) {
      crewLoop:
      for (var crewJson in json['crewOne']) {
        Crew? tempCrew = Crew.fromJson(crewJson);
        if (tempCrew.date == today && tempCrew.status == 'crew') {
          crew = tempCrew;
          break crewLoop;
        }
      }
    }
    if (crew == null && json['crewTwo'] != null && json['crewTwo'].isNotEmpty) {
      crewLoop:
      for (var crewJson in json['crewTwo']) {
        Crew? tempCrew = Crew.fromJson(crewJson);
        if (tempCrew.date == today && tempCrew.status == 'crew') {
          crew = tempCrew;
          break crewLoop;
        }
      }
    }
    if (crew == null && json['crewThree'] != null && json['crewThree'].isNotEmpty) {
      crewLoop:
      for (var crewJson in json['crewThree']) {
        Crew? tempCrew = Crew.fromJson(crewJson);
        if (tempCrew.date == today && tempCrew.status == 'crew') {
          crew = tempCrew;
          break crewLoop;
        }
      }
    }
    if (json['sentCrewRequests'] != null && json['sentCrewRequests'].isNotEmpty) {
      for (var request in json['sentCrewRequests']) {
        CrewRequest crewRequest = CrewRequest.fromJson(request);
        if (crewRequest.status == 'request' && crewRequest.date == today) {
          String id = request['receiver_id'];
          sentCrewRequests[id] = crewRequest;
        } else if (crewRequest.status == 'crew' && crewRequest.date == today) {
          // this piece of code is less than ideal
          // it is specifically to deal with the case we receive a crew request, and the other two are already in a crew
          if (json['id'] != currentUserId) {
            String id = request['receiver_id'];
            sentCrewRequests[id] = crewRequest;
          }
        }
      }
    }
    if (json['receivedCrewRequests'] != null && json['receivedCrewRequests'].isNotEmpty) {
      for (var request in json['receivedCrewRequests']) {
        CrewRequest crewRequest = CrewRequest.fromJson(request);
        if (crewRequest.status == 'request' && crewRequest.date == today) {
          String id = request['sender_id'];
          receivedCrewRequests[id] = crewRequest;
        }
      }
    }
    if (json['sentLikes'] != null && json['sentLikes'].isNotEmpty) {
      for (var likeJson in json['sentLikes']) {
        Like like = Like.fromJson(likeJson);
        if (like.date == today) {
          sentLikes[like.crew!.id] = like;
        }
      }
    }
    if (json['matchConfirmations'] != null && json['matchConfirmations'].isNotEmpty) {
      // log(json['matchConfirmations'].toString());
      for (var matchConfirmation in json['matchConfirmations']) {
        MatchConfirmation pendingMatchConfirmation = MatchConfirmation.fromJson(matchConfirmation);
        if (pendingMatchConfirmation.confirmed != null && pendingMatchConfirmation.confirmed!) {
          Match? match = pendingMatchConfirmation.match;
          if (match != null) {
            if (match.date == today) {
              currentMatch = match;
            } else {
              matchHistory[pendingMatchConfirmation.otherCrewId] = match;
            }
          }
        }
        pendingMatchConfirmations[pendingMatchConfirmation.otherCrewId] = pendingMatchConfirmation;
      }
      matchHistory = orderMatchHistory(matchHistory);
    }
    return Profile(
      id: json['id'] as String?,
      bio: json['bio'] as String?,
      name: json['full_name'] as String?,
      city: json['city'] as String?,
      homeTown: json['home_town'] as String?,
      neighbourhood: json['neighbourhood'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      interestedIn: json['interested_in'] as String?,
      birthday: DateTime.tryParse(json['birthday'].toString()), // DateTime.fromMillisecondsSinceEpoch(json['birthday']),
      occupation: json['occupation'] as String?,
      university: json['university'] as String?,
      subscription: json['subscription'] as String?,
      phone: json['phone'] as String?,
      countryCode: json['country_code'] as String?,
      localNumber: json['local_number'] as String?,
      friends: friends.isNotEmpty ? friends : null,
      sentFriendRequests: sentFriendRequests.isNotEmpty ? sentFriendRequests : null,
      receivedFriendRequests: receivedFriendRequests.isNotEmpty ? receivedFriendRequests : null,
      crew: (crew?.date == today && crew?.status == "crew") ? crew : null,
      sentCrewRequests: sentCrewRequests.isNotEmpty ? sentCrewRequests : null,
      receivedCrewRequests: receivedCrewRequests.isNotEmpty ? receivedCrewRequests : null,
      sentLikes: sentLikes,
      pendingMatchConfirmations: pendingMatchConfirmations,
      currentMatch: currentMatch,
      matchHistory: matchHistory,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
