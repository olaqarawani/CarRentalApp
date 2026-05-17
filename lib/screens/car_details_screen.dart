import 'package:car_rental_appp/screens/customer/create_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/car.dart';
import '../services/api_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final int carId;
  const CarDetailsScreen({super.key, required this.carId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final ApiService api = ApiService();

  Car? car;
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await api.getCarDetails(widget.carId);
      setState(() => car = res);
    } catch (e) {
      setState(() => error = 'Failed to load car details');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          : car == null
          ? const SizedBox()
          : _content(context, car!),
    );
  }

  Widget _content(BuildContext context, Car car) {
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 300,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: const Color(0xFF111827),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                car.image.isEmpty
                    ? Container(color: const Color(0xFFE2E8F0))
                    : Image.network(
                        '$imagesUrl/${car.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) =>
                            Container(color: const Color(0xFFE2E8F0)),
                      ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.58),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(available: car.available),
                      const SizedBox(height: 10),
                      Text(
                        car.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.payments_outlined,
                        label: 'Daily price',
                        value: '${car.pricePerDay} ILS',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.event_available_outlined,
                        label: 'Booking',
                        value: car.available ? 'Open' : 'Closed',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  car.description.isEmpty
                      ? 'No description available.'
                      : car.description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: car.available
                      ? () async {
                          final prefs = await SharedPreferences.getInstance();

                          await prefs.setInt('booking_car_id', car.id);
                          await prefs.setString('booking_car_name', car.type);
                          await prefs.setInt(
                            'booking_daily_price',
                            car.pricePerDay,
                          );

                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateBookingScreen(),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Book Now'),
                ),
                if (!car.available) ...[
                  const SizedBox(height: 10),
                  Text(
                    'This car is currently unavailable for booking.',
                    style: TextStyle(color: colors.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool available;

  const _StatusBadge({required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: available ? const Color(0xFFE8FFF7) : const Color(0xFFFFEDEE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        available ? 'Available' : 'Unavailable',
        style: TextStyle(
          color: available ? const Color(0xFF047857) : const Color(0xFFB42318),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE5ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
