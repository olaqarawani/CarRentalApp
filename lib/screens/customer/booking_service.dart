import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  // ⚠️ Emulator فقط
  static const String baseUrl = 'http://172.20.10.11/car_rental_api';


  /* =========================
     CREATE BOOKING
     ========================= */
  static Future<Map<String, dynamic>> createBooking({
  required int customerId,
  required int carId,
  required String pickup,
  required String dropoff,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  final url = Uri.parse("$baseUrl/booking_create.php");

  final body = {
    "customer_id": customerId,
    "car_id": carId,
    "pickup_location": pickup,
    "dropoff_location": dropoff,
    "start_date": _toYmd(startDate),
    "end_date": _toYmd(endDate),
  };

  final res = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  return jsonDecode(res.body);
}


  /* =========================
     LIST MY BOOKINGS
     ========================= */
  static Future<List<Map<String, dynamic>>> getMyBookings({
  required int customerId,
}) async {
  final url =
      Uri.parse("$baseUrl/bookings_list.php?customer_id=$customerId");

  final res = await http.get(url);
  final decoded = jsonDecode(res.body);

  if (decoded["success"] != true) {
    throw Exception(decoded["message"] ?? "Failed to load bookings");
  }

  final List list = decoded["data"];

  return list
      .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
      .toList();
}

  static Future<Map<String, dynamic>> getBookingDetails({
    required int bookingId,
  }) async {
    final url = Uri.parse("$baseUrl/booking_details.php?id=$bookingId");

    final res = await http.get(url);

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (decoded["success"] != true) {
      throw Exception(decoded["message"] ?? "Failed to load booking details");
    }

    return Map<String, dynamic>.from(decoded["data"]);
  }

  /* =========================
     CANCEL BOOKING (لاحقاً)
     ========================= */
  static Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final url = Uri.parse("$baseUrl/booking_cancel.php");

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": bookingId}),
    );

    return jsonDecode(res.body) as Map<String, dynamic>;
  }


  /* =========================
     HELPERS
     ========================= */
  static String _toYmd(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

      static Future<List<Map<String, dynamic>>> getAvailableCars() async {
  final url = Uri.parse("$baseUrl/cars_available.php");

  final res = await http.get(url);
  final decoded = jsonDecode(res.body);

  if (decoded["success"] != true) {
    throw Exception(decoded["message"] ?? "Failed to load cars");
  }

  final List list = decoded["data"];

  return list
      .map<Map<String, dynamic>>(
        (e) => Map<String, dynamic>.from(e),
      )
      .toList();
}


}
