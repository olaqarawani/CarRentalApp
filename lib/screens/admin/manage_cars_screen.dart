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

    final res = await http.get(Uri.parse('$baseUrl/cars.php'));
    final List data = json.decode(res.body);

    setState(() {
      cars = data.map((e) => Car.fromJson(e)).toList();
      loading = false;
    });
  }

  Future<void> deleteCar(int id) async {
    await http.delete(
      Uri.parse('$baseUrl/cars.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );
    fetchCars();
  }

  void confirmDelete(int carId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Car'),
        content: const Text('Are you sure you want to delete this car?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteCar(carId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// 🔧 FIXED: نرجّع Map مطابق تمامًا للي AddEditCarScreen متوقعه
  Map<String, dynamic> _carToMap(Car car) {
    return {
      'id': car.id,
      'type': car.type,
      'price_per_day': car.pricePerDay.toString(), // مهم
      'description': car.description,
      'available': car.available ? '1' : '0',
      'image': car.image,
    };
  }

  Future<void> openAddEdit(Car? car) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCarScreen(
          car: car == null ? null : _carToMap(car),
        ),
      ),
    );

    if (updated == true) fetchCars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Cars')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddEdit(null),
        icon: const Icon(Icons.add),
        label: const Text('Add Car'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              itemBuilder: (_, i) {
                final car = cars[i];

                return Stack(
                  children: [
                    /// ✅ نفس كرت الكاستمر
                    CarCard(
                      car: car,
                      onTap: () {}, // الأدمن ما بيفتح details
                    ),

                    /// 🔐 Admin actions
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => openAddEdit(car),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
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
    );
  }
}
