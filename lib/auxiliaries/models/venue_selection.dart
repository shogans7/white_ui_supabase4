// ignore_for_file: non_constant_identifier_names

class VenueSelection {
  String? id;
  String? userId;
  String? matchId;
  List<dynamic>? selectedVenues;
  String? createdAt;

  VenueSelection({
    required this.id,
    this.userId,
    this.matchId,
    this.selectedVenues,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'user_id': userId, 'match_id': matchId, 'selected_venues': selectedVenues};

  static VenueSelection fromJson(Map<dynamic, dynamic>? json) {
    return VenueSelection(
      id: json!['id'] as String?,
      userId: json['user_id'] as String?,
      matchId: json['match_id'] as String?,
      selectedVenues: json['selected_venues'] as List<dynamic>?,
      createdAt: json['created_at'] as String?,
    );
  }
}
