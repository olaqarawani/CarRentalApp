class Car {
  final int id;
  final String type;
  final int pricePerDay;
  final bool available;
  final String description;
  final String image; 

  Car({
    required this.id,
    required this.type,
    required this.pricePerDay,
    required this.available,
    required this.description,
    required this.image,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();

  final s = v.toString();
  if (s.contains('.')) {
    return double.tryParse(s)?.round() ?? 0;
  }
  return int.tryParse(s) ?? 0;
}


    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString();
      return s == '1' || s.toLowerCase() == 'true';
    }

    return Car(
      id: parseInt(json['id']),
      type: (json['type'] ?? '').toString(),
      pricePerDay: parseInt(json['price_per_day']),
      available: parseBool(json['available']),
      description: (json['description'] ?? '').toString(),

      // 🔥 FIX HERE
      image: (json['image'] ?? '').toString(),
    );
  }
}
