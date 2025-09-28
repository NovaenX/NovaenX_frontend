class Food {
  final int id;
  final String foodName;
  final double calories;
  final double protein;
  final int quantity;
  final DateTime createdAt;

  Food({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.quantity,
    required this.createdAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] ?? 0,
      foodName: (json['food_name'] ?? "").toString(),
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 1).toInt(),
      // ✅ Parse ISO 8601 datetime
      createdAt: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
                .toLocal() // convert to local timezone
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "food_name": foodName,
      "calories": calories,
      "protein": protein,
      "quantity": quantity,
      "created_date": createdAt.toUtc().toIso8601String(),
    };
  }
}
