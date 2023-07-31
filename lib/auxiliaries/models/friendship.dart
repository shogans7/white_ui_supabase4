// ignore_for_file: non_constant_identifier_names

import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class Friendship {
  String? id;
  String? userId;
  String? friendId;
  Profile? friend;
  String? createdAt;

  Friendship({
    this.id,
    this.userId,
    this.friendId,
    this.friend,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'id': id, 'user_id': userId, 'friend_id': friendId, 'created_at': createdAt};

  static Friendship fromJson(Map<dynamic, dynamic>? json) {
    Profile? friend;
    if (json!['friend'] != null) {
      friend = Profile.fromJson(json['friend']);
    }
    return Friendship(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      friendId: json['friend_id'] as String?,
      friend: friend,
      createdAt: json['created_at'] as String?,
    );
  }
}
