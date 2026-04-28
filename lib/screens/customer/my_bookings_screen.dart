import 'package:flutter/material.dart';
import 'booking_service.dart';
import 'booking_details_screen.dart';
import '../../core/session_manager.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  Future<List<Map<String, dynamic>>>? futureBookings;
  int? customerId;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final id = await SessionManager.getUserId();

    if (id == null) return;

    setState(() {
      customerId = id;
      futureBookings = BookingService.getMyBookings(customerId: id);
    });
  }

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
          "My Bookings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: futureBookings == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: futureBookings,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                final bookings = snapshot.data ?? [];

                if (bookings.isEmpty) {
                  return const Center(child: Text("No bookings yet"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = bookings[index];

                    final carName = (b["car_name"] ?? "").toString();
                    final pickup = (b["pickup"] ?? "").toString();
                    final start = _fmtDate(b["start_date"]);
                    final end = _fmtDate(b["end_date"]);
                    final total = "${b["total_price"]} \$";
                    final status =
                        (b["status"] ?? "").toString().toLowerCase();

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final changed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailsScreen(
                              bookingId:
                                  int.parse(b["id"].toString()),
                            ),
                          ),
                        );

                        if (changed == true) {
                          _loadBookings(); // 🔄 reload
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.directions_car,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    carName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "$start → $end",
                                    style: const TextStyle(
                                        color: Colors.black54),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Pickup: $pickup",
                                    style: const TextStyle(
                                        color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  total,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _StatusChip(status: status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isApproved = status == "approved";
    final isRejected = status == "rejected";

    final bg = isApproved
        ? Colors.green.shade50
        : isRejected
            ? Colors.red.shade50
            : Colors.orange.shade50;

    final fg = isApproved
        ? Colors.green.shade700
        : isRejected
            ? Colors.red.shade700
            : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: fg,
          fontSize: 12,
        ),
      ),
    );
  }
}
