import 'dart:convert';

import 'package:http/http.dart' as http;

import 'event_service.dart';

class GeocodedLocation {
  final double latitude;
  final double longitude;

  const GeocodedLocation({
    required this.latitude,
    required this.longitude,
  });
}

class GeocodingService {
  static Future<GeocodedLocation> geocodeAddress(String address) async {
    final Uri url = Uri.parse('${EventService.baseUrl}/geocode').replace(
      queryParameters: {
        'address': address,
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Could not find this address: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return GeocodedLocation(
      latitude: (jsonData['latitude'] as num).toDouble(),
      longitude: (jsonData['longitude'] as num).toDouble(),
    );
  }
}