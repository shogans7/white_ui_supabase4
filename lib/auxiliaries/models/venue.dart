// ignore_for_file: non_constant_identifier_names

class Venue {
  String? id;
  String? name;
  String? city;
  String? type;
  String? venueUrl;
  String? createdAt;

  Venue({
    required this.id,
    this.name,
    this.city,
    this.type,
    this.venueUrl,
    this.createdAt,
  });

  Map<String, Object?> toJson() => {'name': name, 'city': city, 'type': type, 'venue_url': venueUrl};

  static Venue fromJson(Map<dynamic, dynamic>? json) {
    return Venue(
      id: json!['id'] as String?,
      name: json['name'] as String?,
      city: json['city'] as String?,
      type: json['type'] as String?,
      venueUrl: json['venue_url'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
