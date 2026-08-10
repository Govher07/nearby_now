import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

AppUser? currentUser;

class CurrentUserStorage {
  static const String userKey = 'current_user';
  static const String tokenKey = 'access_token';

  static Future<void> saveUser(AppUser user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      userKey,
      jsonEncode(user.toJson()),
    );

    currentUser = user;
  }

  static Future<AppUser?> loadUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? userJson = prefs.getString(userKey);
    final String? accessToken = prefs.getString(tokenKey);

    if (userJson == null || accessToken == null) {
      currentUser = null;
      return null;
    }

    final Map<String, dynamic> jsonData = jsonDecode(userJson);

    currentUser = AppUser.fromJson(jsonData);

    return currentUser;
  }

  static Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);
    await prefs.remove(tokenKey);

    currentUser = null;
  }

  static Future<void> saveAccessToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> loadAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<Map<String, String>> authorizationHeaders({
    bool includeJsonContentType = false,
  }) async {
    final String? token = await loadAccessToken();
    final Map<String, String> headers = {};

    if (includeJsonContentType) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
