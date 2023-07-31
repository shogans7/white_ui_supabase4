// ignore_for_file: non_constant_identifier_names

import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/match.dart';

class MatchConfirmation {
  String? id;
  String? userId;
  String? ownCrewId;
  String? otherCrewId;
  Crew? ownCrew;
  Crew? otherCrew;
  bool? confirmed;
  String? date;
  String? matchId;
  Match? match;
  String? createdAt;

  MatchConfirmation({
    this.id,
    this.userId,
    this.ownCrewId,
    this.otherCrewId,
    this.ownCrew,
    this.otherCrew,
    this.confirmed,
    this.date,
    this.matchId,
    this.match,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'id': id, 'user_id': userId, 'confirmed': confirmed, 'created_at': createdAt};

  static MatchConfirmation fromJson(Map<dynamic, dynamic>? json) {
    Crew? ownCrew;
    Crew? otherCrew;
    Match? match;
    if (json!['ownCrew'] != null && json['ownCrew'].isNotEmpty) {
      ownCrew = Crew.fromJson(json['ownCrew']);
    }
    if (json['otherCrew'] != null && json['otherCrew'].isNotEmpty) {
      otherCrew = Crew.fromJson(json['otherCrew']);
    }
    if (json['match'] != null) {
      match = Match.fromJson(json['match']);
    }
    return MatchConfirmation(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      ownCrewId: json['own_crew_id'] as String?,
      otherCrewId: json['other_crew_id'] as String?,
      ownCrew: ownCrew,
      otherCrew: otherCrew,
      confirmed: json['confirmed'] as bool?,
      date: json['date'] as String?,
      matchId: json['match_id'] as String?,
      match: match,
      createdAt: json['created_at'] as String?,
    );
  }
}
