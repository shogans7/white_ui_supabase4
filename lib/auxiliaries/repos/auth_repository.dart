import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/helpers/local_functions.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class AuthRepository {
  final supabase = Supabase.instance.client;

  Future<Profile?> attemptAutoLogin() async {
    Profile? userProfile;
    User? user;
    try {
      user = await checkIfUserLoggedIn();
      if (user != null) {
        debugPrint("Automatically logged in");
        userProfile = await getProfileFromUserId(user.id);
      }
    } catch (e) {
      debugPrint("Failed to sign in automatically...");
      rethrow;
    }

    return userProfile;
  }

  Future<User?> checkIfUserLoggedIn() async {
    User? user = supabase.auth.currentUser;
    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  Future<void> signOut() async {}

  Future<User?> signInWithOtp(String phoneNumber, String? name, String? dob) async {
    String? birthday = rearrangeDob(dob);
    List<String>? countryAndLocalNumber = seperatePhoneAndDialCode(phoneNumber);
    String? countryCode;
    String? localNumber;
    if (countryAndLocalNumber != null && countryAndLocalNumber.isNotEmpty) {
      countryCode = countryAndLocalNumber.first;
      localNumber = countryAndLocalNumber.last;
    }
    try {
      await supabase.auth.signInWithOtp(phone: phoneNumber, data: {
        'phone': phoneNumber,
        'full_name': name,
        'birthday': birthday,
        'country_code': countryCode,
        'local_number': localNumber,
      });
      debugPrint("Signing in with OTP....");
    } on Exception catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<User?> verifyOtp(String phoneNumber, String code) async {
    try {
      await supabase.auth.verifyOTP(phone: phoneNumber, token: code, type: OtpType.sms);
      debugPrint("Verifying OTP...");
    } on Exception catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<Profile?> getProfileFromUserId(String userId) async {
    try {
      // get user, get their friendships from friendshiptable
      // on getting friendships, get friend profile, on getting their profile, get their friends
      final stopwatch = Stopwatch()..start();

      String query = '*,'
          // get likes the user has sent, and the crew it was sent to
          'sentLikes:likes!likes_user_id_fkey(*, crew!likes_other_crew_id_fkey(*)),'
          // get the pending match confirmations for user, and ownCrew, otherCrew associated
          'matchConfirmations:match_confirmations!match_confirmations_user_id_fkey(*,'
          'ownCrew:crew!match_confirmations_own_crew_id_fkey(*),'
          'otherCrew:crew!match_confirmations_other_crew_id_fkey(*, '
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          '),'
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
          // get crewrequests user sent, & associated profile
          'sentCrewRequests:crew_requests!crew_requests_sender_id_fkey(*, friend:profiles!crew_requests_receiver_id_fkey(*)),'
          // get friend requests user received, & associated profile
          'receivedCrewRequests:crew_requests!crew_requests_receiver_id_fkey(*, '
          'friend:profiles!crew_requests_sender_id_fkey(*,'
          'sentCrewRequests:crew_requests!crew_requests_sender_id_fkey(*, friend:profiles!crew_requests_receiver_id_fkey(*))'
          ')'
          '),'
          // get crew where user match userIdOne
          // get crews users, and likes the crew has received,
          // get matches it has, & their associated other crew and profiles,
          'crewOne:crew!crew_user_id_one_fkey(*,'
          // get ownCrews receivedlikes & associated profile of sender
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
          ')))),'
          // get match where crewId matches crewIdOne
          // get other crew and associated profiles
          'matchOne:matches!matches_crew_id_one_fkey(*,'
          'otherCrew:matches_crew_id_two_fkey(*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')'
          '),'
          // get match where crewId matches crewIdTwo
          // get other crew and associated profiles
          'matchTwo:matches!matches_crew_id_two_fkey(*,'
          'otherCrew:matches_crew_id_one_fkey(*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')'
          '),'
          // get ownCrews users
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          '),'
          // get crew where user match userIdTwo
          // get crews users, and likes the crew has received,
          // get matches it has, & their associated other crew and profiles,
          'crewTwo:crew!crew_user_id_two_fkey(*,'
          // get ownCrews receivedlikes & associated profile of sender
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
          ')))),'
          // get match where crewId matches crewIdOne
          // get other crew and associated profiles
          'matchOne:matches!matches_crew_id_one_fkey(*,'
          'otherCrew:matches_crew_id_two_fkey(*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')'
          '),'
          // get match where crewId matches crewIdTwo
          // get other crew and associated profiles
          'matchTwo:matches!matches_crew_id_two_fkey(*,'
          'otherCrew:matches_crew_id_one_fkey(*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')'
          '),'
          // get ownCrews users
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          '),'
          // get crew where user match userIdThree
          // get crews users, and likes the crew has received,
          // get matches it has, & their associated other crew and profiles,
          'crewThree:crew!crew_user_id_three_fkey(*,'
          // get ownCrews receivedlikes & associated profile of sender
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
          ')))),'
          // get match where crewId matches crewIdOne
          // get other crew and associated profiles
          'matchOne:matches!matches_crew_id_one_fkey(*,'
          'otherCrew:matches_crew_id_two_fkey(*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')'
          '),'
          // get match where crewId matches crewIdTwo
          // get other crew and associated profiles
          'matchTwo:matches!matches_crew_id_two_fkey(*,'
          'otherCrew:matches_crew_id_one_fkey(*,'
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          ')'
          '),'
          // get ownCrews users
          'userOne:profiles!crew_user_id_one_fkey(*),'
          'userTwo:profiles!crew_user_id_two_fkey(*),'
          'userThree:profiles!crew_user_id_three_fkey(*)'
          '),'
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
      stopwatch.stop();
      debugPrint('Initialisation query executed in ${stopwatch.elapsed.inMilliseconds} milliseconds');

      Profile? userProfile;
      if (data.isNotEmpty) {
        // log(data.toString());
        final stopwatch = Stopwatch()..start();
        userProfile = Profile.fromJson(data);
        debugPrint("Profile loaded for " + data['full_name'].toString());
        stopwatch.stop();
        debugPrint('Crew fromJson executed in ${stopwatch.elapsed.inMilliseconds} milliseconds');
      }
      return userProfile;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
