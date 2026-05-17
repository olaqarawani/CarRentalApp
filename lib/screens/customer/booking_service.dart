import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';

class BookingService {
  static Future<Map<String, dynamic>> createBooking({
    required int customerId,
    required int carId,
    required String pickup,
    required String dropoff,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'customer_id': customerId,
        'car_id': carId,
        'pickup_location': pickup,
        'dropoff_location': dropoff,
        'start_date': _toYmd(startDate),
        'end_date': _toYmd(endDate),
      }),
    );

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getMyBookings({
    required int customerId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/bookings/customer/$customerId'),
    );
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load bookings');
    }

    return (decoded['data'] as List)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>> getBookingDetails({
    required int bookingId,
  }) async {
    final res = await http.get(Uri.parse('$baseUrl/bookings/$bookingId'));
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load booking details');
    }

    return Map<String, dynamic>.from(decoded['data']);
  }

  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookings/cancel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': bookingId}),
    );

    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getAvailableCars() async {
    final res = await http.get(Uri.parse('$baseUrl/cars/available'));
    final decoded = jsonDecode(res.body) as Map<String, dynamic>;

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load cars');
    }

    return (decoded['data'] as List)
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static String _toYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
