import 'package:flutter/material.dart';

import '../core/session_manager.dart';
import '../models/car.dart';
import '../models/filter_state.dart';
import '../services/api_service.dart';
import '../widgets/car_card.dart';
import '../widgets/filters_bottom_sheet.dart';
import '../widgets/profile_avatar_button.dart';
import 'auth/home_screen.dart';
import 'car_details_screen.dart';
import 'customer/customer_profile_screen.dart';

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
  String customerName = '';
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePreview();
    fetchCars();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfilePreview() async {
    final session = await SessionManager.getSession();
    if (!mounted) return;
    setState(() {
      customerName = (session['name'] ?? '').toString();
      profileImage = (session['profileImage'] ?? '').toString();
    });
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

  Future<void> _openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomerProfileScreen()),
    );
    await _loadProfilePreview();
  }

  Future<void> _logoutToHome() async {
    await SessionManager.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _handleBack() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Leaving this screen will end your session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) await _logoutToHome();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore Cars'),
          actions: [
            ProfileAvatarButton(
              imageName: profileImage,
              name: customerName,
              onPressed: _openProfile,
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: fetchCars),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: fetchCars,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find your next rental',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search the fleet and filter by price, type, or availability.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                (car) => CarCard(
                  car: car,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarDetailsScreen(carId: car.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
