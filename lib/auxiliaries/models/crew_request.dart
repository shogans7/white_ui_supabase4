// ignore_for_file: non_constant_identifier_names
import 'package:white_ui_supabase4/auxiliaries/models/profile.dart';
import 'package:white_ui_supabase4/auxiliaries/repos/misc_functions_repository.dart';

class CrewRequest {
  String? id;
  String? senderId;
  String? receiverId;
  Profile? friend;
  String? date;
  String? status;
  String? crewId;
  CrewRequest? relatedRequest;
  // String? thirdUserId;
  // String? thirdUserName;
  // bool? alreadyACrew;
  String? createdAt;

  CrewRequest({
    this.id,
    this.senderId,
    this.receiverId,
    this.friend,
    this.date,
    this.status,
    this.crewId,
    this.relatedRequest,
    // this.thirdUserId,
    // this.thirdUserName,
    // this.alreadyACrew,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'id': id, 'sender_id': senderId, 'receiver_id': receiverId, 'status': status, 'crew_id': crewId, 'created_at': createdAt};

  static CrewRequest fromJson(Map<dynamic, dynamic>? json) {
    String currentUserId = supabase.auth.currentUser!.id;
    Profile? friend;
    CrewRequest? relatedRequest;
    if (json!['friend'] != null) {
      friend = Profile.fromJson(json['friend']);
      // print(friend.name);
      // print(friend.sentCrewRequests?.length);
      if (friend.sentCrewRequests != null && friend.sentCrewRequests!.isNotEmpty) {
        // print("this is runnning");
        friend.sentCrewRequests!.forEach((key, value) {
          // print("for loop");
          // print(key);
          if (key != currentUserId) {
            // print("key not equal current user");
            if (value.crewId == json['crew_id']) {
              relatedRequest = value;
              // print("crew id of this sent request of the friend in this request is the same as the crew id of the request itself");
              // thirdUserId = key;
              // thirdUserName = value.friend!.name;
              // if (value.status == 'crew') {
              //   print("Already a crew!");
              //   alreadyACrew = true;
              // }
            }
          }
        });
      }
    }

    return CrewRequest(
      id: json['id'] as String?,
      senderId: json['sender_id'] as String?,
      receiverId: json['receiver_id'] as String?,
      friend: friend,
      status: json['status'] as String?,
      date: json['date'] as String?,
      crewId: json['crew_id'] as String?,
      relatedRequest: relatedRequest,
      createdAt: json['created_at'] as String?,
    );
  }
}
