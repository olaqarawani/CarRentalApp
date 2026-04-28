import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _loggedIn = 'logged_in';
  static const _userId = 'user_id';
  static const _role = 'role';
  static const _name = 'name';
  static const _email = 'email';

  static Future<void> saveSession(
    int userId,
    String role,
    String name,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedIn, true);
    await prefs.setInt(_userId, userId);
    await prefs.setString(_role, role);
    await prefs.setString(_name, name);
    await prefs.setString(_email, email);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedIn) ?? false;
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_role);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_name);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_email);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userId);
  }

  static Future<bool> isManager() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_role) == 'manager';
  }

  static Future<Map<String, dynamic>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'loggedIn': prefs.getBool(_loggedIn) ?? false,
      'userId': prefs.getInt(_userId),
      'role': prefs.getString(_role),
      'name': prefs.getString(_name),
      'email': prefs.getString(_email),
    };
  }
}
