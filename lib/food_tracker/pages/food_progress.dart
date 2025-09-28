// lib/food_tracker/pages/food_progress.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class FoodProgressPage extends StatefulWidget {
  const FoodProgressPage({super.key});

  @override
  State<FoodProgressPage> createState() => FoodProgressPageState();
}

class FoodProgressPageState extends State<FoodProgressPage> {
  late Future<List<Food>> futureFoods;
  int selectedDays = 7;

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

  Map<String, Map<String, double>> _aggregateDailyData(List<Food> foods) {
    Map<String, Map<String, double>> dailyData = {};

    for (var food in foods) {
      String day = DateFormat('yyyy-MM-dd').format(food.createdAt);

      dailyData.putIfAbsent(day, () => {'calories': 0.0, 'protein': 0.0});
      dailyData[day]!['calories'] =
          (dailyData[day]!['calories'] ?? 0) + food.calories;
      dailyData[day]!['protein'] =
          (dailyData[day]!['protein'] ?? 0) + food.protein;
    }

    return dailyData;
  }

  List<FlSpot> _generateCaloriesSpots(Map<String, Map<String, double>> data) {
    final sortedKeys = data.keys.toList()..sort();
    final recentKeys = sortedKeys.length > selectedDays
        ? sortedKeys.sublist(sortedKeys.length - selectedDays)
        : sortedKeys;

    return recentKeys.asMap().entries.map((entry) {
      final calories = data[entry.value]!['calories'] ?? 0;
      return FlSpot(entry.key.toDouble(), calories);
    }).toList();
  }

  List<FlSpot> _generateProteinSpots(Map<String, Map<String, double>> data) {
    final sortedKeys = data.keys.toList()..sort();
    final recentKeys = sortedKeys.length > selectedDays
        ? sortedKeys.sublist(sortedKeys.length - selectedDays)
        : sortedKeys;

    return recentKeys.asMap().entries.map((entry) {
      final protein = data[entry.value]!['protein'] ?? 0;
      return FlSpot(entry.key.toDouble(), protein);
    }).toList();
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
            return const Center(child: Text('No food data available'));
          }

          final dailyData = _aggregateDailyData(snapshot.data!);
          final caloriesSpots = _generateCaloriesSpots(dailyData);
          final proteinSpots = _generateProteinSpots(dailyData);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time period selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('7 Days'),
                      selected: selectedDays == 7,
                      onSelected: (selected) {
                        setState(() => selectedDays = 7);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('14 Days'),
                      selected: selectedDays == 14,
                      onSelected: (selected) {
                        setState(() => selectedDays = 14);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('30 Days'),
                      selected: selectedDays == 30,
                      onSelected: (selected) {
                        setState(() => selectedDays = 30);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Calories Chart
                const Text(
                  'Daily Calories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'Day ${value.toInt() + 1}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: caloriesSpots,
                          isCurved: true,
                          color: Colors.orange,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Protein Chart
                const Text(
                  'Daily Protein (g)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                'Day ${value.toInt() + 1}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: proteinSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0.3),
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
      ),
    );
  }
}
