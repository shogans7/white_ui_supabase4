import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/like.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match_confirmation.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';

class LikesRepository {
  final supabase = Supabase.instance.client;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  Future<Crew?>  getUsersLikesAndPendingMatchesFromCrewId(String crewId) async {
    try{
      String query = '*,'
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*),'
        'matchConfirmations:match_confirmations!match_confirmations_own_crew_id_fkey(*,'
        'ownCrew:crew!match_confirmations_own_crew_id_fkey(*),'
        'otherCrew:crew!match_confirmations_other_crew_id_fkey(*, '
        'userOne:profiles!crew_user_id_one_fkey(*),'
        'userTwo:profiles!crew_user_id_two_fkey(*),'
        'userThree:profiles!crew_user_id_three_fkey(*)'
        ')'
        // ',match:matches!match_confirmations_match_id_fkey(*,'
        // 'crewOne:crew!matches_crew_id_one_fkey(*,'
        // 'userOne:profiles!crew_user_id_one_fkey(*),'
        // 'userTwo:profiles!crew_user_id_two_fkey(*),'
        // 'userThree:profiles!crew_user_id_three_fkey(*)'
        // '),'
        // 'crewTwo:crew!matches_crew_id_two_fkey(*,'
        // 'userOne:profiles!crew_user_id_one_fkey(*),'
        // 'userTwo:profiles!crew_user_id_two_fkey(*),'           
        // 'userThree:profiles!crew_user_id_three_fkey(*)'
        // '),'
        // 'venue:venues!matches_venue_id_fkey(*)'
        // ')'
        '),'
        'receivedLikes:likes!likes_other_crew_id_fkey(*, profiles!likes_user_id_fkey(*,'
        'friends:friendships!friendships_user_id_fkey(*,'
        'friend:profiles!friendships_friend_id_fkey(*)'
        '),'
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
        '))))';

    final data = await supabase.from('crew').select(query).eq('id', crewId).single();
    if (data.isNotEmpty) {
      Crew? crew = Crew.fromJson(data);
      return crew;
    }  
    } catch(e) {
      rethrow;
    }
  }


  Future<MatchConfirmation?> confirmPendingMatch(MatchConfirmation pendingMatch) async {
    try {
      String query = '*,'
          'ownCrew:crew!match_confirmations_own_crew_id_fkey(*),'
          'otherCrew:crew!match_confirmations_other_crew_id_fkey(*, '
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          '),'
          'match:matches!match_confirmations_match_id_fkey(*, matchConfirmations:match_confirmations!match_confirmations_match_id_fkey(*))';

       final data = await supabase.from('match_confirmations').upsert({'id': pendingMatch.id, 'confirmed': true}).select(query).single();
       if(data.isNotEmpty){
        print(data);
        MatchConfirmation? matchConfirmation = MatchConfirmation.fromJson(data);
        if(matchConfirmation.match != null){

        }
        return matchConfirmation;
       }
    } catch(e) {
        rethrow;
      }
  }

  Future<Like?> sendLike(String userId, Crew ownCrew, Crew otherCrew, bool sentLike) async {
   try{
        String date = formatter.format(DateTime.now());
        Map? like = {
          'user_id': userId,
          'own_crew_id': ownCrew.id
          'other_crew_id': otherCrew.id,
          'like': sentLike,
          'date': date,
        };
        String query = '*, crew!likes_other_crew_id_fkey(*)';
        // TODO: this function should get likes associated with own and othercrew, and filter by date 

        final data = await supabase.from('likes').insert(like).select(query).single();
        if(data.isNotEmpty){
          Like sentLike = Like.fromJson(data);

          if(sentLike.like != null && sentLike.like!) {
          bool match = await isMatch(ownCrew, otherCrew);
           if(match){
            writeMatchConfirmations(ownCrew, otherCrew);
            }
           }
          return sentLike;
        }
    } catch(e) {
        rethrow;
      }
  }


  Future<Map<dynamic, Like>> getOlderLikes(String userId) async {
    Map<dynamic, Like> receivedLikes = {};
    try{

        List<String> previousCrewIds = [];
       

        String query = '*, crewOne:crew!crew_user_id_one_fkey(*), crewTwo:crew!crew_user_id_two_fkey(*), crewThree:crew!crew_user_id_three_fkey(*)';
        final data = await supabase.from('profiles').select(query).eq('id', userId).single();

        if(data.isNotEmpty){
          final crewData = data['crewOne'] + data['crewTwo'] + data['crewThree'];
          if(crewData.isNotEmpty){
            for(var crew in crewData){
             
              if(crew['status'] == 'crew' && crew['date'] != today){
                previousCrewIds.add(crew['id']);
              }
            }
          }

          if(previousCrewIds.isNotEmpty){
            String date = formatter.format(DateTime.now());
            String likesQuery = '*, user:profiles!likes_user_id_fkey(*,'
          'friends:friendships!friendships_user_id_fkey(*,'
          'friend:profiles!friendships_friend_id_fkey(*)'
          '),'
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
          ')))';
            final likesData = await supabase.from('likes').select(likesQuery).neq('date', date).in_('other_crew_id', previousCrewIds); 
            if(likesData.isNotEmpty){
              for(var likeJson in likesData){
                Like like = Like.fromJson(likeJson);
                if(like.user != null){
                  receivedLikes[like.user!.id] = like;
                }
              }
            }
          }
        }
        return receivedLikes;
        } catch(e) {
          rethrow;
        }
  }

  Future<Map<dynamic, Match>?> getTodaysMatches() async {
    Map<dynamic, Match> todaysMatches = {};
    try {
        String today = formatter.format(DateTime.now());
        String query = '*,'
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
          'venue:venues!matches_venue_id_fkey(*)';

          final data = await supabase.from('matches').select(query).eq('date', today);
          if(data.isNotEmpty){
            for(var matchJson in data){
              Match match = Match.fromJson(matchJson);
              todaysMatches[match.id] = match;
            }
            return todaysMatches;
          }
    } catch(e) {
      rethrow;
    }
  }

  Future<Map<dynamic, Match>?> getOlderMatches() async {
    Map<dynamic, Match> olderMatches = {};
    try {
        String today = formatter.format(DateTime.now());
        String query = '*,'
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
          'venue:venues!matches_venue_id_fkey(*)';

          final data = await supabase.from('matches').select(query).neq('date', today);
          if(data.isNotEmpty){
            for(var matchJson in data){
              Match match = Match.fromJson(matchJson);
              olderMatches[match.id] = match;
            }
            return olderMatches;
          }
    } catch(e) {
      rethrow;
    }
  }

  Future<bool> isMatch(Crew ownCrew, Crew otherCrew) async {
    bool isMatch = true;
    String? crewIdOne = ownCrew.id;
    String? crewIdTwo = otherCrew.id;
    Map<dynamic, Profile>? allUsers = {}..addAll(ownCrew.users!)..addAll(otherCrew.users!);
    List<dynamic> ids = allUsers.keys.toList();
    Map<dynamic, bool> likes = {};
    for(var id in ids) {
      likes[id] = false;
    }
    
    if(crewIdOne != null && crewIdTwo != null)  {
      String query = '*';
      final data = await supabase.from('likes').select(query).or('and(ownCrewId.eq.$crewIdOne, otherCrewId.eq.$crewIdTwo),and(ownCrewId.eq.$crewIdTwo, otherCrewId.eq.$crewIdOne)');
      if(data.isNotEmpty){
          for(var elem in data){
          Like like = Like.fromJson(elem);
          bool? alreadyLiked = likes[like.userId];
          if(!(alreadyLiked == true)){
            likes[like.userId] = like.like ?? false;
          }
        }
      }
    }

    isMatch = (likes.values).every((like) => like);
    return isMatch;
  }

  Future<void> writeMatchConfirmations(Crew ownCrew, Crew otherCrew) async {
    String date = formatter.format(DateTime.now());
    List<Map> ownMatchConfirmations = generateMatchConfirmations(ownCrew, otherCrew.id!, date);
    List<Map> otherMatchConfirmations = generateMatchConfirmations(otherCrew, ownCrew.id!, date);
    List<Map> matchConfirmations = ownMatchConfirmations..addAll(otherMatchConfirmations);
    await supabase.from('match_confirmations').insert(matchConfirmations);
  }


  List<Map> generateMatchConfirmations(Crew crew, String otherCrewId, String date) {
    List<Map> matchConfirmations = [];
    String ownCrewId = crew.id!;
    for(var user in crew.users!.values){
      Map matchConfirmation = {
        'user_id': user.id,
        'own_crew_id': ownCrewId,
        'other_crew_id': otherCrewId,
        'date': date
      };
      matchConfirmations.add(matchConfirmation);
    }
    return matchConfirmations;
  }

  /*
  TODO: MATCHING PROBLEM STATEMENT
  The way I am dealing with matches/ confirmations is a little all over the place
  On authRepo first query, I check if I have a match by if matchConfirmation has associated matchId
  But here, to check if others have also confirmed, would require having matchId

  If I put matchId in all matchConfirmations, I need a match status in match table to control fully confirmed and latent matches
  This would also require a somewhat convoluted way of getting matchConfirmations out of match json
  The advantage is that before fully matched, its possible to get all related matchConfirmations in one place with one query

  Other possibility is a db function that checks and inserts matchId when all have confirmed (then pushes)
  This has the advantage that matchConfirmation matchId controls the 'status' of a match, if non-null, then match is good to go

  Is there another way i can access a users matches in first query (& more generally?)
  It seems a little convoluted that I have to go via matchConfirmations
  */

}


