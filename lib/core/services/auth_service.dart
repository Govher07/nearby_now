import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../config/api_config.dart';
import '../data/current_user.dart';

class AuthService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<AppUser> _readAuthResponse(http.Response response) async {
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final String token = jsonData['access_token'] as String;
    final AppUser user = AppUser.fromJson(
      jsonData['user'] as Map<String, dynamic>,
    );
    await CurrentUserStorage.saveAccessToken(token);
    return user;
  }

  static Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final Uri url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register user');
    }

    return _readAuthResponse(response);
  }

  static Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final Uri url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid email or password');
    }

    return _readAuthResponse(response);
  }
}
