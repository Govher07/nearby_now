import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

AppUser? currentUser;

class CurrentUserStorage {
  static const String userKey = 'current_user';

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

    if (userJson == null) {
      return null;
    }

    final Map<String, dynamic> jsonData = jsonDecode(userJson);

    currentUser = AppUser.fromJson(jsonData);

    return currentUser;
  }

  static Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);

    currentUser = null;
  }
}