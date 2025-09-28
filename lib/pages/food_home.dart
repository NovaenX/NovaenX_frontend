import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';
import "food_edit.dart";
import "food_add.dart";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "novaenx",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const MyHomePage(title: 'Food Logger'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Map<String, List<Food>> groupFoodsByDay(List<Food> foods) {
  Map<String, List<Food>> grouped = {};

  for (var food in foods) {
    // Extract only the date part from createdAt
    String day =
        "${food.createdAt.year}-${food.createdAt.month.toString().padLeft(2, '0')}-${food.createdAt.day.toString().padLeft(2, '0')}";

    grouped.putIfAbsent(day, () => []);
    grouped[day]!.add(food);
  }

  return grouped;
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Food>> futureFoods;

  @override
  void initState() {
    super.initState();
    futureFoods = ApiService.fetchFoods(); // fetch foods from backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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

          // Group by day
          var groupedFoods = groupFoodsByDay(snapshot.data!);

          // Sort days in descending order (latest first)
          final sortedDays = groupedFoods.keys.toList()
            ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

          return ListView(
            children: sortedDays.map((day) {
              List<Food> foods = groupedFoods[day]!;

              // Sort foods inside the day (latest first)
              foods.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              // Refresh the list whether it was edited or deleted
                              setState(() {
                                futureFoods = ApiService.fetchFoods();
                              });
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
            MaterialPageRoute(builder: (context) => AddFoodPage()),
          );

          if (newFood != null) {
            // Refresh the list after adding a new food
            setState(() {
              futureFoods = ApiService.fetchFoods();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
