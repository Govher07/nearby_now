import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/event.dart';

class EventService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Event>> fetchEvents() async {
    final Uri url = Uri.parse('$baseUrl/events');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load events');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) {
      return Event.fromJson(json);
    }).toList();
  }


  //Post/event
  static Future<Event> createEvent(Event event) async{

    //create an url (meaning parse the baseUrl which was created
    //on top of the this class) this is same for GET and POST
    final Uri url = Uri.parse('$baseUrl/events');

    //WAIT for response 
    //unlike GET in POST  we need to include the body 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event.toJson()),
    );

    if(response.statusCode != 200 && response.statusCode != 201){
      throw Exception('Failed to create event.');
    }

    //decode the data 
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    return Event.fromJson(jsonData);

  }

  //DELETE/events function
 static Future<void> deleteEvent(String eventId) async {
  final Uri url = Uri.parse('$baseUrl/events/$eventId');

  final response = await http.delete(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to delete event');
  }
}
}