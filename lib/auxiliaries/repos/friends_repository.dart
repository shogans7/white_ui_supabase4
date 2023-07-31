import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/models/friend_request.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class FriendsRepository {
  final supabase = Supabase.instance.client;

  Future<FriendRequest?> sendFriendRequest(String friendId) async {
    String userId = supabase.auth.currentUser!.id;
    try {
      final data = await supabase.from('friend_requests').insert({'sender_id': userId, 'receiver_id': friendId, 'status': "request"}).select().single();
      if (data.isNotEmpty) {
        FriendRequest friendRequest = FriendRequest.fromJson(data);
        return friendRequest;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String requestId, String friendId) async {
    String userId = supabase.auth.currentUser!.id;
    try {
      await supabase.from('friend_requests').upsert({'id': requestId, 'status': "friend"});
      await supabase.from('friendships').insert([
        {'user_id': userId, 'friend_id': friendId},
        {'user_id': friendId, 'friend_id': userId}
      ]);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> deleteFriendRequest(String requestId) async {
    try {
      await supabase.from('friend_requests').delete().match({'id': requestId});
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Map<dynamic, Profile>?> loadMoreSuggestedFriends(List<dynamic>? idsToAvoid, int rangeFrom, int rangeTo) async {
    Map<dynamic, Profile> newSuggestedFriends = {};
    try {
      final data = await supabase
          .from('profiles')
          .select('*, friends:friendships!friendships_user_id_fkey(*, friend:profiles!friendships_friend_id_fkey(*))')
          .not('id', 'in', idsToAvoid)
          .range(rangeFrom, rangeTo);
      if (data.isNotEmpty) {
        for (var elt in data) {
          Profile user = Profile.fromJson(elt);
          String id = user.id!;
          newSuggestedFriends[id] = user;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
    return newSuggestedFriends;
  }

  Future<Profile?> getUserAndFriendshipRelationshipsFromUserId(String userId) async {
    try {
      String query = '*,'

          // get friend requests user sent, & associated profile
          'sentFriendRequests:friend_requests!friend_requests_sender_id_fkey(*, friend:profiles!friend_requests_receiver_id_fkey(*)),'
          // get friend requests user received, & associated profile
          'receivedFriendRequests:friend_requests!friend_requests_receiver_id_fkey(*, friend:profiles!friend_requests_sender_id_fkey(*)),'
          // get user friendships, associated profile & their friends (list of profiles)
          'friends:friendships!friendships_user_id_fkey(*,'
          'friend:profiles!friendships_friend_id_fkey(*,'
          'friends:friendships!friendships_user_id_fkey(*,'
          'friend:profiles!friendships_friend_id_fkey(*,'
          'friends:friendships!friendships_user_id_fkey(*,'
          'friend:profiles!friendships_friend_id_fkey(*)'
          ')'
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
}
