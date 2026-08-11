import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../data/current_user.dart';
import '../models/event.dart';
import '../models/saved_event.dart';

class SavedEventService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<Event>> fetchSavedEvents() async {
    final Uri url = Uri.parse('$baseUrl/saved-events');

    final response = await http.get(
      url,
      headers: await CurrentUserStorage.authorizationHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load saved events: ${response.body}');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) => Event.fromJson(json)).toList();
  }

  static Future<SavedEvent> saveEvent(Event event) async {
    final Uri url = Uri.parse('$baseUrl/saved-events');

    final response = await http.post(
      url,
      headers: await CurrentUserStorage.authorizationHeaders(
        includeJsonContentType: true,
      ),
      body: jsonEncode({
        'event_id': event.id,
        'source': event.source ?? 'nearby_now',
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'date': event.date,
        'time': event.time,
        'location': event.location,
        'latitude': event.latitude,
        'longitude': event.longitude,
        'image_url': event.imageUrl,
        'external_url': event.externalUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save event: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return SavedEvent.fromJson(jsonData);
  }

  static Future<void> removeSavedEvent(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/saved-events/$eventId');

    final response = await http.delete(
      url,
      headers: await CurrentUserStorage.authorizationHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove saved event: ${response.body}');
    }
  }
}
