class Food {
  final int id;
  final String foodName;
  final double calories;
  final double protein;
  final DateTime createdAt;

  Food({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.createdAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'],
      foodName: json['food_name'],
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
