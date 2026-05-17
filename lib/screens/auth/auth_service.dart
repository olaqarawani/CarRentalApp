import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';

class AuthService {
  static Future<Map?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(res.body);
    return data['success'] ? data['user'] : null;
  }
}
