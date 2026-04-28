import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const baseUrl = 'http://192.168.1.16/car_rental_api';

  static Future<Map?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(res.body);
    return data['success'] ? data['user'] : null;
  }
}
