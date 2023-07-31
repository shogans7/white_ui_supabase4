// ignore_for_file: non_constant_identifier_names

import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/venue.dart';

class Match {
  String? id;
  String? crewIdOne;
  String? crewIdTwo;
  Crew? crewOne;
  Crew? crewTwo;
  String? date;
  String? venueId;
  Venue? venue;
  String? createdAt;

  Match({
    required this.id,
    this.crewIdOne,
    this.crewIdTwo,
    this.crewOne,
    this.crewTwo,
    this.date,
    this.venueId,
    this.venue,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'crew_id_one': crewIdOne, 'crew_id_two': crewIdTwo, 'date': date};

  static Match fromJson(Map<dynamic, dynamic>? json) {
    Crew? crewOne;
    Crew? crewTwo;
    Venue? venue;
    if (json!['crewOne'] != null) {
      crewOne = Crew.fromJson(json['crewOne']);
    }
    if (json['crewTwo'] != null) {
      crewTwo = Crew.fromJson(json['crewTwo']);
    }
    if (json['venue'] != null) {
      venue = Venue.fromJson(json['venue']);
    }
    return Match(
      id: json['id'] as String?,
      crewIdOne: json['crew_id_one'] as String?,
      crewIdTwo: json['crew_id_two'] as String?,
      crewOne: crewOne,
      crewTwo: crewTwo,
      date: json['date'] as String?,
      venueId: json['venue_id'] as String?,
      venue: venue,
      createdAt: json['created_at'] as String?,
    );
  }
}
