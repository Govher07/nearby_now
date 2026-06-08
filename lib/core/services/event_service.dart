import 'dart:convert';
import 'dart:math';

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

  static double calculateDistanceInMiles({
    required double userLatitude,
    required double userLongitude,
    required double eventLatitude,
    required double eventLongitude,
  }) {
    const double earthRadiusMiles = 3958.8;

    final double lat1 = _degreesToRadians(userLatitude);
    final double lon1 = _degreesToRadians(userLongitude);
    final double lat2 = _degreesToRadians(eventLatitude);
    final double lon2 = _degreesToRadians(eventLongitude);

    final double latDifference = lat2 - lat1;
    final double lonDifference = lon2 - lon1;

    final double a = sin(latDifference / 2) * sin(latDifference / 2) +
        cos(lat1) *
            cos(lat2) *
            sin(lonDifference / 2) *
            sin(lonDifference / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMiles * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

 static List<Event> applyDistanceFromUser({
  required List<Event> events,
  required double userLatitude,
  required double userLongitude,
}) {
  return events.map((event) {
    if (event.latitude == 0.0 && event.longitude == 0.0) {
      return event;
    }

    final double calculatedDistance = calculateDistanceInMiles(
      userLatitude: userLatitude,
      userLongitude: userLongitude,
      eventLatitude: event.latitude,
      eventLongitude: event.longitude,
    );

    return event.copyWith(
      distance: double.parse(calculatedDistance.toStringAsFixed(1)),
    );
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
  List<Event> internalEvents = [];

  try {
    internalEvents = await fetchEvents();
  } catch (error) {
    print('Local events failed: $error');
  }

  try {
    final position = await LocationService.getCurrentLocation();

    final List<Event> externalEvents = await fetchExternalEvents(
      lat: position.latitude,
      lng: position.longitude,
      radius: 25,
    );

    final List<Event> allEvents = [
      ...internalEvents,
      ...externalEvents,
    ];

    return applyDistanceFromUser(
      events: allEvents,
      userLatitude: position.latitude,
      userLongitude: position.longitude,
    );
  } catch (error) {
    print('External events or location failed: $error');

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

  // GET /my-events/{ownerId}/analytics
  static Future<Map<String, int>> fetchBusinessAnalytics(String ownerId) async {
    final Uri url = Uri.parse('$baseUrl/my-events/$ownerId/analytics');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load business analytics: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return {
      'total_events': (jsonData['total_events'] as num?)?.toInt() ?? 0,
      'total_views': (jsonData['total_views'] as num?)?.toInt() ?? 0,
      'total_saves': (jsonData['total_saves'] as num?)?.toInt() ?? 0,
    };
  }

  // GET /events/{eventId}/save-count
  static Future<int> fetchSaveCount(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/save-count');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load save count: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return (jsonData['save_count'] as num?)?.toInt() ?? 0;
  }

  // POST /events/{eventId}/view
  static Future<int> addView(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/view');

    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to add view: ${response.body}');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return (jsonData['views'] as num?)?.toInt() ?? 0;
  }

  static Future<void> recordEventView(String eventId) async {
    await addView(eventId);
  }

  // GET /events/{eventId}/analytics
  static Future<Map<String, dynamic>> fetchEventAnalytics(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/analytics');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load event analytics: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
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