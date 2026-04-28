import 'package:flutter/material.dart';
import 'booking_service.dart';

class BookingDetailsScreen extends StatelessWidget {
  final int bookingId;
  const BookingDetailsScreen({super.key, required this.bookingId});

  String _fmtDate(dynamic d) {
    final s = d?.toString() ?? "";
    if (s.length < 10) return s;
    final y = s.substring(0, 4);
    final m = s.substring(5, 7);
    final day = s.substring(8, 10);
    return "$day/$m/$y";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: BookingService.getBookingDetails(bookingId: bookingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final b = snapshot.data!;
          final carName = (b["car_name"] ?? "").toString();
          final status = (b["status"] ?? "").toString();
          final pickup = (b["pickup"] ?? "").toString();
          final dropoff = (b["dropoff"] ?? "").toString();
          final start = _fmtDate(b["start_date"]);
          final end = _fmtDate(b["end_date"]);
          final total = "${b["total_price"]} \$";

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    carName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _row("Status", status),
                  _row("Pickup", pickup),
                  _row("Drop-off", dropoff),
                  _row("Start", start),
                  _row("End", end),
                  const Divider(height: 28),
                  _row("Total", total, bold: true),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("Cancel Booking"),
                              content: const Text(
                                "Are you sure you want to cancel this booking?\nThis action cannot be undone.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text("No, keep it"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Yes, cancel"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm != true) return;

                        try {
                          final res = await BookingService.cancelBooking(bookingId);

                          if (res["success"] == true) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Booking cancelled successfully")),
                            );

                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res["message"] ?? "Cancel failed")),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      },


                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.cancel, color: Colors.white),
                      label: const Text(
                        "Cancel Booking",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
