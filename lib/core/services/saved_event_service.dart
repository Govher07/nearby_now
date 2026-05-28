import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saved_event.dart';


class SavedEventService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<SavedEvent>> fetchSavedEvents() async {
    final Uri url = Uri.parse('$baseUrl/saved-events');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load saved events');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) {
      return SavedEvent.fromJson(json);
    }).toList();
  }

  static Future<SavedEvent> saveEvent(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/saved-events');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'event_id': eventId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save event');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return SavedEvent.fromJson(jsonData);
  }

  static Future<void> removeSavedEvent(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/saved-events/$eventId');

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to remove saved event');
    }
  }
}