// ignore_for_file: non_constant_identifier_names

import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';

class FriendRequest {
  String? id;
  String? senderId;
  String? receiverId;
  Profile? friend;
  String? status;
  String? createdAt;

  FriendRequest({
    this.id,
    this.senderId,
    this.receiverId,
    this.friend,
    this.status,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'id': id, 'sender_id': senderId, 'receiver_id': receiverId, 'status': status, 'created_at': createdAt};

  static FriendRequest fromJson(Map<dynamic, dynamic>? json) {
    Profile? friend;
    if (json!['friend'] != null) {
      friend = Profile.fromJson(json['friend']);
    }
    return FriendRequest(
      id: json['id'] as String?,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      friend: friend,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
