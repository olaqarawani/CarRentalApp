import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../models/car.dart';
import '../../widgets/car_card.dart';
import 'add_edit_car_screen.dart';

class ManageCarsScreen extends StatefulWidget {
  const ManageCarsScreen({super.key});

  @override
  State<ManageCarsScreen> createState() => _ManageCarsScreenState();
}

class _ManageCarsScreenState extends State<ManageCarsScreen> {
  List<Car> cars = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    setState(() => loading = true);

    final res = await http.get(Uri.parse('$baseUrl/cars'));
    final data = json.decode(res.body) as List;

    if (!mounted) return;
    setState(() {
      cars = data.map((e) => Car.fromJson(e)).toList();
      loading = false;
    });
  }

  Future<void> deleteCar(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );
    await fetchCars();
  }

  Future<void> confirmDelete(int carId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete car'),
        content: const Text('This vehicle will be removed from the catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) await deleteCar(carId);
  }

  Map<String, dynamic> _carToMap(Car car) {
    return {
      'id': car.id,
      'type': car.type,
      'price_per_day': car.pricePerDay.toString(),
      'description': car.description,
      'available': car.available ? '1' : '0',
      'image': car.image,
    };
  }

  Future<void> openAddEdit(Car? car) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddEditCarScreen(car: car == null ? null : _carToMap(car)),
      ),
    );

    if (updated == true) await fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Cars')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddEdit(null),
        icon: const Icon(Icons.add),
        label: const Text('Add car'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchCars,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cars.length,
                itemBuilder: (_, i) {
                  final car = cars[i];

                  return Stack(
                    children: [
                      CarCard(car: car, onTap: () => openAddEdit(car)),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          elevation: 2,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => openAddEdit(car),
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => confirmDelete(car.id),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
