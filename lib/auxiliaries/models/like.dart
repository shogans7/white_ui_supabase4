// ignore_for_file: non_constant_identifier_names

import 'package:white_ui_supabase4/auxiliaries/models/crew.dart';
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class Like {
  String? id;
  String? userId;
  String? ownCrewId;
  String? otherCrewId;
  Profile? user;
  Crew? crew;
  bool? like;
  String? date;
  String? createdAt;

  Like({
    required this.id,
    this.userId,
    this.ownCrewId,
    this.otherCrewId,
    this.user,
    this.crew,
    this.like,
    this.date,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'id': id, 'user_id': userId, 'own_crew_id': ownCrewId, 'other_crew_id': otherCrewId, 'like': like, 'date': date};

  static Like fromJson(Map<dynamic, dynamic>? json) {
    Profile? user;
    Crew? crew;
    if (json!['user'] != null) {
      user = Profile.fromJson(json['user']);
    }
    if (json['crew'] != null) {
      crew = Crew.fromJson(json['crew']);
    }
    return Like(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      ownCrewId: json['own_crew_id'] as String?,
      otherCrewId: json['other_crew_id'] as String?,
      user: user,
      crew: crew,
      like: json['like'] as bool?,
      date: json['date'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
