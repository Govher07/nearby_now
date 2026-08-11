import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

AppUser? currentUser;

class CurrentUserStorage {
  static const String userKey = 'current_user';
  static const String tokenKey = 'access_token';
  static String? _sessionAccessToken;

  static Future<void> saveUser(AppUser user, {bool persist = true}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    currentUser = user;

    if (persist) {
      await prefs.setString(userKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(userKey);
    }
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
    _sessionAccessToken = null;

    await prefs.remove(userKey);
    await prefs.remove(tokenKey);

    currentUser = null;
  }

  static Future<void> saveAccessToken(
    String token, {
    bool persist = true,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _sessionAccessToken = token;

    if (persist) {
      await prefs.setString(tokenKey, token);
    } else {
      await prefs.remove(tokenKey);
    }
  }

  static Future<String?> loadAccessToken() async {
    if (_sessionAccessToken != null) {
      return _sessionAccessToken;
    }

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
