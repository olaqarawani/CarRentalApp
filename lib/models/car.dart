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
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.round();

      final text = value.toString();
      if (text.contains('.')) return double.tryParse(text)?.round() ?? 0;
      return int.tryParse(text) ?? 0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      final text = value.toString().toLowerCase();
      return text == '1' || text == 'true';
    }

    return Car(
      id: parseInt(json['id']),
      type: (json['type'] ?? '').toString(),
      pricePerDay: parseInt(json['price_per_day']),
      available: parseBool(json['available']),
      description: (json['description'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }
}
