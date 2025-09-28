import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/api_service.dart';
import 'workout_details.dart';

class WorkoutHomePage extends StatefulWidget {
  const WorkoutHomePage({super.key});

  @override
  State<WorkoutHomePage> createState() => _WorkoutHomePageState();
}

class _WorkoutHomePageState extends State<WorkoutHomePage> {
  late Future<List<Workout>> futureWorkouts;

  @override
  void initState() {
    super.initState();
    futureWorkouts = ApiService.fetchWorkouts();
  }

  Future<void> _startNewWorkout() async {
    final newWorkout = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutDetailPage()),
    );

    if (newWorkout != null) {
      setState(() {
        futureWorkouts = ApiService.fetchWorkouts();
      });
    }
  }

  Future<void> _copyPreviousWorkout() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      await ApiService.copyWorkoutFromDate(pickedDate);
      setState(() {
        futureWorkouts = ApiService.fetchWorkouts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Workout Tracker")),
      body: FutureBuilder<List<Workout>>(
        future: futureWorkouts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No workouts available"));
          }

          final workouts = snapshot.data!;
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text(workout.name),
                subtitle: Text(
                  "Created: ${workout.createdDate.toLocal().toString().split(' ')[0]}",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailPage(workout: workout),
                    ),
                  ).then((_) {
                    setState(() {
                      futureWorkouts = ApiService.fetchWorkouts();
                    });
                  });
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "newWorkout",
            onPressed: _startNewWorkout,
            tooltip: "Start New Workout",
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "copyWorkout",
            onPressed: _copyPreviousWorkout,
            tooltip: "Copy Previous Workout",
            child: const Icon(Icons.copy),
          ),
        ],
      ),
    );
  }
}
