import 'package:car_rental_appp/screens/customer/customer_profile_screen.dart';
import 'package:flutter/material.dart';

import '../models/car.dart';
import '../models/filter_state.dart';
import '../services/api_service.dart';
import '../widgets/car_card.dart';
import '../widgets/filters_bottom_sheet.dart';
import 'car_details_screen.dart';

class CarsListScreen extends StatefulWidget {
  const CarsListScreen({super.key});

  @override
  State<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  final ApiService api = ApiService();
  final TextEditingController searchCtrl = TextEditingController();

  FilterState filter = FilterState();
  List<Car> cars = [];
  bool loading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchCars() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await api.getCars(
        filter: filter,
        searchQuery: searchCtrl.text,
      );
      setState(() => cars = result);
    } catch (e) {
      setState(() => error = 'Failed to load cars');
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> openFilters() async {
    final result = await showModalBottomSheet<FilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FiltersBottomSheet(initial: filter),
    );

    if (result != null) {
      setState(() => filter = result);
      await fetchCars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Cars'),
        actions: [
          // 👤 Customer Profile
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'My Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerProfileScreen(),
                ),
              );
            },
          ),

          // 🔄 Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCars,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: fetchCars,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _searchAndActions(),
            const SizedBox(height: 14),

            if (loading) const LinearProgressIndicator(),

            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 10),

            Text(
              'Results (${cars.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            if (!loading && cars.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: Text('No cars found')),
              ),

            ...cars.map(
              (c) => CarCard(
                car: c,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CarDetailsScreen(carId: c.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchAndActions() {
    return Column(
      children: [
        TextField(
          controller: searchCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => fetchCars(),
          decoration: InputDecoration(
            hintText: 'Search cars...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                searchCtrl.clear();
                fetchCars();
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: openFilters,
                icon: const Icon(Icons.tune),
                label: const Text('Filters'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: fetchCars,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
