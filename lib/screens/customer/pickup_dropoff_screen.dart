import 'package:car_rental_appp/core/session_manager.dart';
import 'package:flutter/material.dart';
import 'booking_service.dart';
import 'my_bookings_screen.dart';

class PickupDropoffScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final int dailyPrice;
  final String carName;
  final int carId;
  


  const PickupDropoffScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.dailyPrice,
    required this.carName,
    required this.carId,
  });

  @override
  State<PickupDropoffScreen> createState() => _PickupDropoffScreenState();
}

class _PickupDropoffScreenState extends State<PickupDropoffScreen> {
  String? pickup;
  String? dropoff;

  final List<String> locations = const [
    'Ramallah - Al Manara',
    'Ramallah - Al Tireh',
    'Ramallah - Al Masyoun',
    'Ramallah - City Center',
    'Al-Bireh',
    'Beitunia',
    'Birzeit',
  ];

  int get totalDays => widget.endDate.difference(widget.startDate).inDays + 1;
  int get totalPrice => totalDays * widget.dailyPrice;

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _confirm() async {
  if (pickup == null || dropoff == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select pickup & drop-off')),
    );
    return;
  }

  final userId = await SessionManager.getUserId();

  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in')),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final result = await BookingService.createBooking(
      customerId: userId, // ✅ الصح
      carId: widget.carId,
      pickup: pickup!,
      dropoff: dropoff!,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking created successfully ✅")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Booking failed")),
      );
    }
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request failed: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final canConfirm = pickup != null && dropoff != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'Pickup & Drop-off',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.lightBlue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.carName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dates: ${_fmt(widget.startDate)} → ${_fmt(widget.endDate)}",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total: $totalDays days • $totalPrice \$",
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Choose locations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),

            const Text('Pickup location',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: pickup,
              hint: const Text('Select pickup'),
              items: locations
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => pickup = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade100),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text('Drop-off location',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: dropoff,
              hint: const Text('Select drop-off'),
              items: locations
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => dropoff = v),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade100),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canConfirm ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  disabledBackgroundColor: Colors.blueGrey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
