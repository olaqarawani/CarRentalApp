import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/car.dart';
import '../models/filter_state.dart';

class ApiService {
  Future<List<Car>> getCars({
    required FilterState filter,
    required String searchQuery,
  }) async {
    final uri = Uri.parse('$baseUrl/cars');

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load cars');
    }

    final List data = jsonDecode(res.body);

    List<Car> cars = data
        .map<Car>((e) => Car.fromJson(e as Map<String, dynamic>))
        .toList();

    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      cars = cars.where((c) {
        return c.type.toLowerCase().contains(q);
      }).toList();
    }

    if (filter.type != 'All') {
      cars = cars.where((c) => c.type == filter.type).toList();
    }

    if (filter.availableOnly) {
      cars = cars.where((c) => c.available).toList();
    }

    cars = cars.where((c) {
      return c.pricePerDay >= filter.minPrice &&
          c.pricePerDay <= filter.maxPrice;
    }).toList();

    if (filter.sort == 'PriceLowHigh') {
      cars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    } else if (filter.sort == 'PriceHighLow') {
      cars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    }

    return cars;
  }

  Future<Car> getCarDetails(int id) async {
    final uri = Uri.parse('$baseUrl/cars/$id');

    final res = await http.get(uri);

    if (res.statusCode != 200) throw Exception('Car not found');

    return Car.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
