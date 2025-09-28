import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController(
    text: "0",
  );
  final TextEditingController proteinController = TextEditingController(
    text: "0",
  );
  final TextEditingController quantityController = TextEditingController(
    text: "1",
  );
  final GlobalKey _textFieldKey = GlobalKey();
  DateTime selectedDate = DateTime.now();

  List<Food> allFoods = [];
  List<Food> filteredFoods = [];
  bool showSuggestions = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadFoods();
    nameController.addListener(_onSearchChanged);
  }

  Future<void> _loadFoods() async {
    try {
      final foods = await ApiService.fetchFoods();
      setState(() {
        allFoods = foods;
      });
    } catch (e) {
      print("Error loading foods: $e");
    }
  }

  void _onSearchChanged() {
    final query = nameController.text.toLowerCase().trim();

    if (query.isEmpty) {
      _removeOverlay();
      setState(() {
        showSuggestions = false;
        filteredFoods = [];
      });
      return;
    }

    Map<String, Food> uniqueFoods = {};
    for (var food in allFoods) {
      final foodNameLower = food.foodName.toLowerCase();
      if (foodNameLower.contains(query)) {
        if (!uniqueFoods.containsKey(foodNameLower)) {
          uniqueFoods[foodNameLower] = food;
        }
      }
    }

    setState(() {
      filteredFoods = uniqueFoods.values.toList();
      showSuggestions = filteredFoods.isNotEmpty;
    });

    if (showSuggestions) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    final RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + 16,
        top: offset.dy + size.height + 8,
        width: size.width,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final food = filteredFoods[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    food.foodName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${food.calories.toStringAsFixed(0)} cal • ${food.protein.toStringAsFixed(1)}g protein',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward, size: 16),
                  onTap: () => _selectFood(food),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectFood(Food food) {
    _removeOverlay();
    setState(() {
      nameController.text = food.foodName;
      caloriesController.text = food.calories.toString();
      proteinController.text = food.protein.toString();
      // Keep quantity as 1 when selecting from suggestions
      quantityController.text = "1";
      showSuggestions = false;
      filteredFoods = [];
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    nameController.removeListener(_onSearchChanged);
    nameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    quantityController.dispose();
    super.dispose();
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
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a food name")));
      return;
    }

    final newFood = Food(
      id: 0,
      foodName: nameController.text,
      calories: double.tryParse(caloriesController.text) ?? 0,
      protein: double.tryParse(proteinController.text) ?? 0,
      quantity: int.tryParse(quantityController.text) ?? 1,
      createdAt: selectedDate,
    );

    try {
      await ApiService.createFood(newFood);
      Navigator.pop(context, newFood);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error creating food: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _removeOverlay();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Add Food")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  key: _textFieldKey,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Food Name",
                    hintText: "Start typing to see suggestions...",
                    suffixIcon: nameController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              nameController.clear();
                              _removeOverlay();
                            },
                          )
                        : const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Calories",
                          hintText: "0",
                        ),
                        onTap: _removeOverlay,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Protein (g)",
                          hintText: "0",
                        ),
                        onTap: _removeOverlay,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Qty",
                          hintText: "1",
                        ),
                        onTap: _removeOverlay,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _removeOverlay();
                        _pickDate();
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveFood,
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
