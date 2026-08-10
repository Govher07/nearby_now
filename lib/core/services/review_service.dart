import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../config/api_config.dart';
import '../data/current_user.dart';

class ReviewService {
  static const String baseUrl = ApiConfig.baseUrl;

  // GET /events/{event_id}/reviews
  static Future<List<Review>> fetchReviews(String eventId) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/reviews');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load reviews');
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData.map((json) {
      return Review.fromJson(json);
    }).toList();
  }

  // POST /events/{event_id}/reviews
  static Future<Review> createReview({
    required String eventId,
    required Review review,
  }) async {
    final Uri url = Uri.parse('$baseUrl/events/$eventId/reviews');

    final response = await http.post(
      url,
      headers: await CurrentUserStorage.authorizationHeaders(
        includeJsonContentType: true,
      ),
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create review');
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return Review.fromJson(jsonData);
  }
}
