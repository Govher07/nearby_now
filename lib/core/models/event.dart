class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String date;
  final String time;
  final double distance;
  final double latitude;
  final double longitude;
  final String? ownerId;
  final String? imageUrl;
  final String? source;

  final String? addressLine;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.date,
    required this.time,
    required this.distance,
    required this.latitude,
    required this.longitude,
    this.ownerId,
    this.imageUrl,
    this.source,
    this.addressLine,
    this.city,
    this.state,
    this.country,
    this.zipCode,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.5,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 40.785091,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -73.968285,
      ownerId: json['owner_id']?.toString(),
      imageUrl: json['image_url']?.toString(),
      source: json['source']?.toString(),
      addressLine: json['address_line']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      zipCode: json['zip_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'date': date,
      'time': time,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
      'image_url': imageUrl,
      'source': source,
      'address_line': addressLine,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
    };
  }

  String get fullAddress {
    final List<String> parts = [
      addressLine,
      city,
      state,
      country,
      zipCode,
    ]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!)
        .toList();

    if (parts.isNotEmpty) {
      return parts.join(', ');
    }

    return location;
  }
}