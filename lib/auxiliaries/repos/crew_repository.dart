import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class CrewRepository {
  final supabase = Supabase.instance.client;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  Future<List<Crew>?> getCrews(Profile user, int rangeStart, int rangeEnd) async {
    String? interestedIn = user.crew?.interestedIn ?? user.interestedIn;
    String? city = user.crew?.city ?? user.city;
    String date = formatter.format(DateTime.now());
    List<Crew>? crews = [];

    if (interestedIn != null) {
      try {
        String query = '*,'
            'receivedLikes:likes!likes_other_crew_id_fkey(*, profiles!likes_user_id_fkey(*)),'
            'userOne:profiles!crew_user_id_one_fkey(*,'
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
            'friends:friendships!friendships_user_id_fkey(*,'
            'friend:profiles!friendships_friend_id_fkey(*)'
            ')),'
            'userTwo:profiles!crew_user_id_two_fkey(*,'
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
            'friends:friendships!friendships_user_id_fkey(*,'
            'friend:profiles!friendships_friend_id_fkey(*)'
            ')),'
            'userThree:profiles!crew_user_id_three_fkey(*,'
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
            'friends:friendships!friendships_user_id_fkey(*,'
            'friend:profiles!friendships_friend_id_fkey(*)'
            '))';
        final data = await supabase.from('crew').select(query).eq('city', city).eq('date', date).eq('status', "crew").eq('type', interestedIn).range(rangeStart, rangeEnd);
        // .neq('userIdOne', userId)
        // .neq('userIdTwo', userId)
        // .neq('userIdThree', userId);

        if (data.isNotEmpty) {
          for (var element in data) {
            Crew? crew = Crew.fromJson(element);
            // TODO: need filter for own crew here?
            crews.add(crew);
          }
        }
      } catch (e) {
        debugPrint(e.toString());
        rethrow;
      }
    }
    return crews;
  }

  Future<CrewRequest?> sendCrewRequest(Profile currentUser, String friendId) async {
    String userId = currentUser.id!;
    String date = formatter.format(DateTime.now());
    String type = (currentUser.gender == 'Female')
        ? 'Women'
        : (currentUser.gender == 'Male')
            ? 'Men'
            : 'Mixed';
    String? city = currentUser.city; // TODO: should city come from somewhere else in the app
    try {
      final crewData =
          await supabase.from('crew').insert({'userIdOne': userId, 'date': date, 'status': "request", 'type': type, 'interestedIn': currentUser.interestedIn, 'city': city}).select().single();
      if (crewData.isNotEmpty) {
        Crew crew = Crew.fromJson(crewData);
        String query = '*,'
            'friend:profiles!crew_requests_receiver_id_fkey(*)';
        final data = await supabase.from('crew_requests').insert({'sender_id': userId, 'receiver_id': friendId, 'date': date, 'status': "request", 'crew_id': crew.id}).select(query).single();
        if (data.isNotEmpty) {
          CrewRequest crewRequest = CrewRequest.fromJson(data);
          return crewRequest;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<CrewRequest?> addThirdToCrewRequest(String crewId, String friendId) async {
    String userId = supabase.auth.currentUser!.id;
    String date = formatter.format(DateTime.now());
    try {
      String query = '*,'
          'friend:profiles!crew_requests_receiver_id_fkey(*)';
      final data = await supabase.from('crew_requests').insert({'sender_id': userId, 'receiver_id': friendId, 'date': date, 'status': "request", 'crew_id': crewId}).select(query).single();
      if (data.isNotEmpty) {
        CrewRequest crewRequest = CrewRequest.fromJson(data);
        return crewRequest;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Crew?> confirmCrewRequest(CrewRequest request, Profile currentUser, Profile friend) async {
    String userId = supabase.auth.currentUser!.id;
    // String friendId = friend.id!;
    Crew? crew;
    String type = (currentUser.gender == 'Female')
        ? 'Women'
        : (currentUser.gender == 'Male')
            ? 'Men'
            : 'Mixed';
    String? interestedIn;

    try {
      String requestQuery = '*, crew:crew_requests__crew_id_fkey(*)';
      final requestData = await supabase.from('crew_requests').upsert({'id': request.id, 'status': "crew"}).select(requestQuery).single();

      // the following block determines if there is already a second user in the crew
      // this determines which userId column tto upsert the confirmation
      String userUpsertPosition = 'userIdTwo';
      if (requestData.isNotEmpty) {
        Crew crewBeforeUpsert = Crew.fromJson(requestData['crew']);
        if (crewBeforeUpsert.userIdTwo != null) {
          userUpsertPosition = 'userIdThree';
        }
        type = (crewBeforeUpsert.type == type) ? type : 'Mixed'; // if users are same gender, keep this as group type, otherwise mixed
        interestedIn = (crewBeforeUpsert.interestedIn == currentUser.interestedIn) ? crewBeforeUpsert.interestedIn : 'Mixed'; // if users are interestedIn same, keep this, otherwise mixed
      }

      String query = '*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')';

      final data = await supabase
          .from('crew')
          .upsert({
            'id': request.crewId,
            userUpsertPosition: userId,
            'status': "crew",
            'type': type,
            'interestedIn': interestedIn,
          })
          .select(query)
          .single();
      if (data.isNotEmpty) {
        crew = Crew.fromJson(data);
      }
      return crew;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteCrewRequest(String requestId) async {
    try {
      await supabase.from('crew_requests').delete().match({'id': requestId});
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> addCrewPhoto(String crewId, String imageUrl) async {
    try {
      await supabase.from('crew').upsert({'id': crewId, 'group_photo_url': imageUrl});
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> removeCrew(String crewId) async {
    try {
      await supabase.from('crew').delete().match({'id': crewId});
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
