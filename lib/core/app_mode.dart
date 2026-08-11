import 'package:shared_preferences/shared_preferences.dart';

const String selectedAppRoleKey = 'selected_app_role';

String selectedAppRole = 'event_seeker';

Future<bool> loadSelectedAppRole() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? savedRole = prefs.getString(selectedAppRoleKey);

  if (savedRole == null) {
    return false;
  }

  selectedAppRole = savedRole;
  return true;
}

Future<void> saveSelectedAppRole(String role) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  selectedAppRole = role;

  await prefs.setString(selectedAppRoleKey, role);
}
