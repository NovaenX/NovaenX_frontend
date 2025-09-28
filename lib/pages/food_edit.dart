import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class FoodDetailPage extends StatefulWidget {
  final Food food;

  const FoodDetailPage({super.key, required this.food});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  late TextEditingController nameController;
  late TextEditingController caloriesController;
  late TextEditingController proteinController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.food.foodName);
    caloriesController = TextEditingController(
      text: widget.food.calories.toString(),
    );
    proteinController = TextEditingController(
      text: widget.food.protein.toString(),
    );
    selectedDate = widget.food.createdAt;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveFood() async {
    final updatedFood = Food(
      id: widget.food.id,
      foodName: nameController.text,
      calories: double.tryParse(caloriesController.text) ?? 0,
      protein: double.tryParse(proteinController.text) ?? 0,
      createdAt: selectedDate,
    );

    // Call backend API to update
    await ApiService.updateFood(updatedFood);

    Navigator.pop(context, updatedFood); // return updated food
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Food"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              // Confirm deletion
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Entry"),
                  content: Text(
                    "Are you sure you want to delete '${widget.food.foodName}'?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  await ApiService.deleteFood(widget.food.id); // backend delete
                  Navigator.pop(context, true); // return true for deletion
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Food Name"),
            ),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Calories"),
            ),
            TextField(
              controller: proteinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Protein"),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                const Spacer(),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveFood, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
