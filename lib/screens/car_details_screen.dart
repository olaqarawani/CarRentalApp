import 'package:car_rental_appp/screens/customer/create_booking_screen.dart';
import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import '../core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 260,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                car.image.isEmpty
                    ? Container(color: Colors.grey.shade300)
                    : Image.network(
                        '$imagesUrl/${car.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade300),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.35),
                      ],
                    ),
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
                Text(
                  car.type,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _pill(car.type),
                    const SizedBox(width: 10),
                    _pill(
                      car.available ? 'Available' : 'Not Available',
                      bg: car.available
                          ? const Color(0xFFE7F8EE)
                          : const Color(0xFFFFE8E6),
                      fg: car.available
                          ? const Color(0xFF12B76A)
                          : const Color(0xFFF04438),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  car.description.isEmpty
                      ? 'No description available.'
                      : car.description,
                ),

                const SizedBox(height: 22),

                _priceBox(car),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
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

                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _priceBox(Car car) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined),
          const SizedBox(width: 10),
          const Text(
            'Price per day',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Text(
            '${car.pricePerDay} ₪',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _pill(
    String text, {
    Color bg = const Color(0xFFEFF1FF),
    Color fg = const Color(0xFF4C5FFF),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }
}
