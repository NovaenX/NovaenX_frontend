import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food.dart';

class ApiService {
  static final String baseUrl = "http://134.209.155.105:8000/api/food_tracker";

  static Future<List<Food>> fetchFoods() async {
    final response = await http.get(
      Uri.parse(baseUrl),
    ); // replace /foods with your endpoint

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  static Future<void> updateFood(Food food) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${food.id}/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "food_name": food.foodName,
        "calories": food.calories,
        "protein": food.protein,
        "created_date": food.createdAt.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update food");
    }
  }

  static Future<void> deleteFood(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id/"));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Failed to delete food");
    }
  }

  static Future<void> createFood(Food food) async {
    final response = await http.post(
      Uri.parse("$baseUrl/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "food_name": food.foodName,
        "calories": food.calories,
        "protein": food.protein,
        "created_date": food.createdAt.toIso8601String(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to create food");
    }
  }
}
