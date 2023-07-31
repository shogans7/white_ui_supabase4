import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue_selection.dart';

class VenueRepository {
  final supabase = Supabase.instance.client;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  Future<List<Venue>?> getVenues(String city) async {
    try {
      List<Venue>? venues = [];
      final data = await supabase.from('venues').select().eq('city', city);
      if (data.isNotEmpty) {
        for (var elem in data) {
          venues.add(Venue.fromJson(elem));
        }
      }
      return venues;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, Match>?> getTonightsMatchesAtVenue(String venueId) async {
    Map<dynamic, Match>? tonightsMatches = {};
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

      final data = await supabase.from('matches').select(query).eq('date', today).eq('venue_id', venueId);

      if (data.isNotEmpty) {
        for (var matchJson in data) {
          Match match = Match.fromJson(matchJson);
          tonightsMatches[match.id] = match;
        }
        return tonightsMatches;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<dynamic, Match>?> getOlderMatchesAtVenue(String venueId) async {
    Map<dynamic, Match>? tonightsMatches = {};
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

      final data = await supabase.from('matches').select(query).neq('date', today).eq('venue_id', venueId);

      if (data.isNotEmpty) {
        for (var matchJson in data) {
          Match match = Match.fromJson(matchJson);
          tonightsMatches[match.id] = match;
        }
        return tonightsMatches;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<VenueSelection?> getVenueSelection(String userId, String matchId) async {
    VenueSelection? venueSelection;
    try {
      String query = '*';
      final data = await supabase.from('venue_selection').select(query).eq('user_id', userId).eq('match_id', matchId).neq('deleted_flag', true).single();
      if (data.isNotEmpty) {
        venueSelection = VenueSelection.fromJson(data);
      }

      return venueSelection;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSelectedVenues(String selectionId, List<dynamic> selectedVenues) async {
    try {
      await supabase.from('venue_selection').upsert({'id': selectionId, 'selected_venues': selectedVenues});
    } catch (e) {
      rethrow;
    }
  }
}
