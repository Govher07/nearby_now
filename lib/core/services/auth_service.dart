import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/user.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';

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

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return AppUser.fromJson(jsonData);
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

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return AppUser.fromJson(jsonData);
  }
}