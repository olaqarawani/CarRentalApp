import 'package:flutter/material.dart';

import '../../core/session_manager.dart';
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
  bool saving = false;

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
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _confirm() async {
    if (pickup == null || dropoff == null) {
      _showMessage('Please select pickup and drop-off locations');
      return;
    }

    final userId = await SessionManager.getUserId();
    if (!mounted) return;

    if (userId == null) {
      _showMessage('Please login again to continue');
      return;
    }

    setState(() => saving = true);

    try {
      final result = await BookingService.createBooking(
        customerId: userId,
        carId: widget.carId,
        pickup: pickup!,
        dropoff: dropoff!,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request created')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
        );
      } else {
        _showMessage(result['message'] ?? 'Booking failed');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not create the booking');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = pickup != null && dropoff != null && !saving;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup & Drop-off')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.carName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dates: ${_fmt(widget.startDate)} to ${_fmt(widget.endDate)}',
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: $totalDays days - $totalPrice ILS',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Choose Locations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          _locationDropdown(
            label: 'Pickup location',
            value: pickup,
            icon: Icons.my_location_outlined,
            onChanged: (value) => setState(() => pickup = value),
          ),
          const SizedBox(height: 14),
          _locationDropdown(
            label: 'Drop-off location',
            value: dropoff,
            icon: Icons.location_on_outlined,
            onChanged: (value) => setState(() => dropoff = value),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: canConfirm ? _confirm : null,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(saving ? 'Submitting...' : 'Confirm Booking'),
          ),
        ],
      ),
    );
  }

  Widget _locationDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: locations
          .map(
            (location) =>
                DropdownMenuItem(value: location, child: Text(location)),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
