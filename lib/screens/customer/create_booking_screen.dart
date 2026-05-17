import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_profile_screen.dart';
import 'pickup_dropoff_screen.dart';

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
  bool loadingCar = true;

  @override
  void initState() {
    super.initState();
    _loadCarFromPrefs();
  }

  Future<void> _loadCarFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      carId = prefs.getInt('booking_car_id') ?? 0;
      carName = prefs.getString('booking_car_name') ?? '';
      dailyPrice = prefs.getInt('booking_daily_price') ?? 0;
      loadingCar = false;
    });
  }

  int get totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  int get totalPrice => totalDays * dailyPrice;

  String _fmt(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (startDate ?? now)
        : (endDate ?? startDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(startDate!)) endDate = null;
      } else {
        if (startDate != null && picked.isBefore(startDate!)) {
          _showMessage('End date must be after the start date');
          return;
        }
        endDate = picked;
      }
    });
  }

  void _continue() {
    if (carId == 0 || dailyPrice <= 0) {
      _showMessage('Choose a car before creating a booking');
      return;
    }

    if (startDate == null || endDate == null) {
      _showMessage('Select pickup and return dates');
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canContinue = startDate != null && endDate != null && carId != 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Booking'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
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
      body: loadingCar
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _panel(
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.directions_car_filled_outlined,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              carName.isEmpty ? 'No car selected' : carName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dailyPrice <= 0
                                  ? 'Go back and choose a vehicle'
                                  : '$dailyPrice ILS per day',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rental Dates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _dateTile(
                              title: 'Pickup',
                              value: _fmt(startDate),
                              icon: Icons.calendar_today_outlined,
                              onTap: () => _pickDate(isStart: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateTile(
                              title: 'Return',
                              value: _fmt(endDate),
                              icon: Icons.event_available_outlined,
                              onTap: () => _pickDate(isStart: false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _panel(
                  child: Column(
                    children: [
                      _summaryRow('Daily price', '$dailyPrice ILS'),
                      const SizedBox(height: 10),
                      _summaryRow(
                        'Total days',
                        totalDays == 0 ? '-' : '$totalDays',
                      ),
                      const Divider(height: 26),
                      _summaryRow(
                        'Total',
                        totalDays == 0 ? '-' : '$totalPrice ILS',
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: canContinue ? _continue : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continue'),
                ),
              ],
            ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6E8F0)),
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
    final colors = Theme.of(context).colorScheme;
    final empty = value == 'Select date';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: empty ? Colors.black45 : colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
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
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
