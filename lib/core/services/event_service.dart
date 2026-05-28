import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/event.dart';
import 'location_service.dart';

class EventService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  // GET /events
  static Future<List<Event>> fetchEvents() async {
    final Uri url = Uri.parse('$baseUrl/events');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load events: ${response.body}');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) {
      return Event.fromJson(json);
    }).toList();
  }

  // GET /external-events
  static Future<List<Event>> fetchExternalEvents({
    double lat = 47.6062,
    double lng = -122.3321,
    int radius = 25,
    String? keyword,
  }) async {
    String urlString =
        '$baseUrl/external-events?lat=$lat&lng=$lng&radius=$radius';

    if (keyword != null && keyword.trim().isNotEmpty) {
      urlString += '&keyword=${Uri.encodeComponent(keyword.trim())}';
    }

    final Uri url = Uri.parse(urlString);

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load external events: ${response.body}');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) {
      return Event.fromJson(json);
    }).toList();
  }

  // Internal Nearby Now events + external Ticketmaster events
 static Future<List<Event>> fetchAllEvents() async {
  final List<Event> internalEvents = await fetchEvents();

  try {
    final position = await LocationService.getCurrentLocation();

    final List<Event> externalEvents = await fetchExternalEvents(
      lat: position.latitude,
      lng: position.longitude,
      radius: 25,
    );

    return [
      ...internalEvents,
      ...externalEvents,
    ];
  } catch (error) {
    // If location fails, still show internal Nearby Now events.
    return internalEvents;
  }
}

  // POST /events
  static Future<Event> createEvent(Event event) async {
    final Uri url = Uri.parse('$baseUrl/events');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return Event.fromJson(jsonData);
  }

  // DELETE /events/{eventId}
  static Future<void> deleteEvent(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId');

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event: ${response.body}');
    }
  }

  // GET /my-events/{ownerId}
  static Future<List<Event>> fetchMyEvents(String ownerId) async {
    final Uri url = Uri.parse('$baseUrl/my-events/$ownerId');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load my events: ${response.body}');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) {
      return Event.fromJson(json);
    }).toList();
  }

  // GET /events/{eventId}/save-count
  static Future<int> fetchSaveCount(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/save-count');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load save count: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return jsonData['save_count'] ?? 0;
  }

  // POST /events/{eventId}/view
  static Future<int> addView(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/view');

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to add view: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return jsonData['views'] ?? 0;
  }

  // PUT /events/{eventId}
  static Future<Event> updateEvent({
    required String eventId,
    required Event event,
  }) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update event: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return Event.fromJson(jsonData);
  }
}