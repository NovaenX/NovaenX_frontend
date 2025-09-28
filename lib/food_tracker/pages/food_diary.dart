// lib/food_tracker/pages/food_diary.dart

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import 'food_edit.dart';
import 'food_add.dart';

class FoodDiaryPage extends StatefulWidget {
  final VoidCallback? onFoodChanged;

  const FoodDiaryPage({super.key, this.onFoodChanged});

  @override
  State<FoodDiaryPage> createState() => FoodDiaryPageState();
}

Map<String, List<Food>> groupFoodsByDay(List<Food> foods) {
  Map<String, List<Food>> grouped = {};

  for (var food in foods) {
    String day =
        "${food.createdAt.year}-${food.createdAt.month.toString().padLeft(2, '0')}-${food.createdAt.day.toString().padLeft(2, '0')}";

    grouped.putIfAbsent(day, () => []);
    grouped[day]!.add(food);
  }

  return grouped;
}

class FoodDiaryPageState extends State<FoodDiaryPage> {
  late Future<List<Food>> futureFoods;

  @override
  void initState() {
    super.initState();
    futureFoods = ApiService.fetchFoods();
  }

  void refresh() {
    setState(() {
      futureFoods = ApiService.fetchFoods();
    });
  }

  double _calculateTotalCalories(List<Food> foods) {
    return foods.fold(0.0, (sum, food) => sum + food.calories);
  }

  double _calculateTotalProtein(List<Food> foods) {
    return foods.fold(0.0, (sum, food) => sum + food.protein);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Food>>(
        future: futureFoods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No foods available'));
          }

          var groupedFoods = groupFoodsByDay(snapshot.data!);

          final sortedDays = groupedFoods.keys.toList()
            ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

          return ListView(
            children: sortedDays.map((day) {
              List<Food> foods = groupedFoods[day]!;
              foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              double totalCalories = _calculateTotalCalories(foods);
              double totalProtein = _calculateTotalProtein(foods);

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat(
                              'EEE, MMM d, yyyy',
                            ).format(foods.first.createdAt),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${totalCalories.toStringAsFixed(0)} cal',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                '${totalProtein.toStringAsFixed(1)}g protein',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      ...foods.map(
                        (food) => ListTile(
                          title: Text(food.foodName),
                          subtitle: Text(
                            'Calories: ${food.calories}, Protein: ${food.protein}g',
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FoodDetailPage(food: food),
                              ),
                            );

                            if (result != null) {
                              refresh();
                              widget.onFoodChanged?.call();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newFood = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodPage()),
          );

          if (newFood != null) {
            refresh();
            widget.onFoodChanged?.call();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
