// lib/food_tracker/pages/food_summary.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class FoodSummaryPage extends StatefulWidget {
  const FoodSummaryPage({super.key});

  @override
  State<FoodSummaryPage> createState() => FoodSummaryPageState();
}

class FoodSummaryPageState extends State<FoodSummaryPage> {
  late Future<List<Food>> futureFoods;

  @override
  void initState() {
    super.initState();
    futureFoods = ApiService.fetchFoods();
  }

  Map<String, dynamic> _calculateStats(List<Food> foods, int days) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));

    final recentFoods = foods
        .where((food) => food.createdAt.isAfter(cutoffDate))
        .toList();

    if (recentFoods.isEmpty) {
      return {
        'avgCalories': 0.0,
        'avgProtein': 0.0,
        'totalCalories': 0.0,
        'totalProtein': 0.0,
        'totalMeals': 0,
        'daysLogged': 0,
      };
    }

    double totalCalories = recentFoods.fold(
      0.0,
      (sum, food) => sum + food.calories,
    );
    double totalProtein = recentFoods.fold(
      0.0,
      (sum, food) => sum + food.protein,
    );

    // Count unique days
    Set<String> uniqueDays = recentFoods
        .map((food) => DateFormat('yyyy-MM-dd').format(food.createdAt))
        .toSet();

    int daysLogged = uniqueDays.length;

    return {
      'avgCalories': daysLogged > 0 ? totalCalories / daysLogged : 0.0,
      'avgProtein': daysLogged > 0 ? totalProtein / daysLogged : 0.0,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalMeals': recentFoods.length,
      'daysLogged': daysLogged,
    };
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Food>>(
      future: futureFoods,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No food data available'));
        }

        final foods = snapshot.data!;
        final last7Days = _calculateStats(foods, 7);
        final last30Days = _calculateStats(foods, 30);
        final allTime = _calculateStats(
          foods,
          365 * 10,
        ); // Effectively all time

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last 7 Days
              const Text(
                'Last 7 Days',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Avg Calories',
                      last7Days['avgCalories'].toStringAsFixed(0),
                      'per day',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Protein',
                      '${last7Days['avgProtein'].toStringAsFixed(1)}g',
                      'per day',
                      Icons.fitness_center,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Meals',
                      last7Days['totalMeals'].toString(),
                      'logged',
                      Icons.restaurant,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Days Logged',
                      last7Days['daysLogged'].toString(),
                      'of 7 days',
                      Icons.calendar_today,
                      Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Last 30 Days
              const Text(
                'Last 30 Days',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Avg Calories',
                      last30Days['avgCalories'].toStringAsFixed(0),
                      'per day',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Protein',
                      '${last30Days['avgProtein'].toStringAsFixed(1)}g',
                      'per day',
                      Icons.fitness_center,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Calories',
                      last30Days['totalCalories'].toStringAsFixed(0),
                      'consumed',
                      Icons.whatshot,
                      Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Total Protein',
                      '${last30Days['totalProtein'].toStringAsFixed(1)}g',
                      'consumed',
                      Icons.shield,
                      Colors.lightBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // All Time
              const Text(
                'All Time',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.fastfood,
                          color: Colors.amber,
                        ),
                        title: const Text('Total Meals Logged'),
                        trailing: Text(
                          allTime['totalMeals'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.calendar_month,
                          color: Colors.teal,
                        ),
                        title: const Text('Days with Logs'),
                        trailing: Text(
                          allTime['daysLogged'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                        title: const Text('Total Calories'),
                        trailing: Text(
                          allTime['totalCalories'].toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.fitness_center,
                          color: Colors.blue,
                        ),
                        title: const Text('Total Protein'),
                        trailing: Text(
                          '${allTime['totalProtein'].toStringAsFixed(1)}g',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
