import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pickup_dropoff_screen.dart';
import 'customer_profile_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  DateTime? startDate;
  DateTime? endDate;

  int carId = 0;
  String carName = '';
  int dailyPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadCarFromPrefs();
  }

  Future<void> _loadCarFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      carId = prefs.getInt('booking_car_id') ?? 0;
      carName = prefs.getString('booking_car_name') ?? '';
      dailyPrice = prefs.getInt('booking_daily_price') ?? 0;
    });
  }

  int get totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  int get totalPrice => totalDays * dailyPrice;

  String _fmt(DateTime? d) {
    if (d == null) return "Select date";
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.lightBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      } else {
        if (startDate != null && picked.isBefore(startDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("End date must be after start date")),
          );
          return;
        }
        endDate = picked;
      }
    });
  }

  Future<void> _continue() async {
    if (carId == 0 || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing booking information")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PickupDropoffScreen(
          carId: carId,
          carName: carName,
          dailyPrice: dailyPrice,
          startDate: startDate!,
          endDate: endDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = startDate != null && endDate != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        title: const Text(
          "Create Booking",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ===== Selected Car Card (نفس الثيم) =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.lightBlue.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$carName\n$dailyPrice ₪ per day",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== Dates =====
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rental Dates",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _dateTile(
                          title: "Start",
                          value: _fmt(startDate),
                          icon: Icons.play_circle_fill,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateTile(
                          title: "End",
                          value: _fmt(endDate),
                          icon: Icons.stop_circle,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ===== Summary =====
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _summaryRow("Daily price", "$dailyPrice ₪"),
                  const SizedBox(height: 8),
                  _summaryRow(
                    "Total days",
                    totalDays == 0 ? "-" : "$totalDays",
                  ),
                  const Divider(height: 22),
                  _summaryRow(
                    "Total",
                    totalDays == 0 ? "-" : "$totalPrice ₪",
                    bold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            /// ===== Continue =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canContinue ? _continue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  disabledBackgroundColor: Colors.blueGrey.shade200,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _dateTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isEmpty = value == "Select date";
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: isEmpty ? Colors.grey : Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
