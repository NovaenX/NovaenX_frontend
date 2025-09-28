// lib/food_tracker/pages/food_home.dart

import 'package:flutter/material.dart';
import 'food_diary.dart';
import 'food_progress.dart';
import 'food_summary.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Diary"),
            Tab(icon: Icon(Icons.show_chart), text: "Progress"),
            Tab(icon: Icon(Icons.analytics), text: "Summary"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FoodDiaryPage(),
          FoodProgressPage(),
          FoodSummaryPage(),
        ],
      ),
    );
  }
}
