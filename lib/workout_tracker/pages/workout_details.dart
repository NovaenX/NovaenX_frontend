import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/api_service.dart';

class WorkoutDetailPage extends StatefulWidget {
  final Workout? workout;

  const WorkoutDetailPage({super.key, this.workout});

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  late TextEditingController nameController;
  late TextEditingController notesController;
  late List<WorkoutSet> sets;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.workout?.name ?? '');
    notesController = TextEditingController(text: widget.workout?.notes ?? '');
    sets = widget.workout?.sets ?? [];
  }

  void _addSet() {
    setState(() {
      sets.add(
        WorkoutSet(
          id: 0, // 0 means new set, backend will assign ID
          exercise: Exercise(
            id: 0,
            name: "New Exercise",
            createdDate: DateTime.now(),
          ),
          setNumber: sets.length + 1,
          reps: 10,
          weight: 20.0,
          notes: "",
          createdDate: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _saveWorkout() async {
    final workout = Workout(
      id: widget.workout?.id, // null if new workout
      name: nameController.text,
      notes: notesController.text,
      createdDate: widget.workout?.createdDate ?? DateTime.now(),
      sets: sets,
      totalSets: sets.length,
    );

    final savedWorkout = await ApiService.saveWorkout(workout);

    // Return with updated ID (important for further edits)
    Navigator.pop(context, savedWorkout);
  }

  Future<void> _deleteWorkout() async {
    final id = widget.workout?.id;
    if (id != null) {
      await ApiService.deleteWorkout(id); // ✅ now it's int, not int?
      Navigator.pop(context, null);
    }
  }

  Future<void> _editSetDialog(WorkoutSet set, int index) async {
    final repsController = TextEditingController(text: set.reps.toString());
    final weightController = TextEditingController(text: set.weight.toString());
    final notesController = TextEditingController(text: set.notes ?? "");
    final exerciseController = TextEditingController(text: set.exercise.name);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Set ${set.setNumber}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exerciseController,
              decoration: const InputDecoration(labelText: "Exercise Name"),
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: "Reps"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Notes"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                sets[index] = WorkoutSet(
                  id: set.id,
                  exercise: Exercise(
                    id: set.exercise.id,
                    name: exerciseController.text,
                    createdDate: set.exercise.createdDate,
                  ),
                  setNumber: set.setNumber,
                  reps: int.tryParse(repsController.text) ?? set.reps,
                  weight: double.tryParse(weightController.text) ?? set.weight,
                  notes: notesController.text,
                  createdDate: set.createdDate,
                );
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout == null ? "New Workout" : "Edit Workout"),
        actions: [
          if (widget.workout != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteWorkout,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Workout Name"),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: "Notes"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sets.length,
                itemBuilder: (context, index) {
                  final set = sets[index];
                  return ListTile(
                    title: Text("${set.exercise.name} - Set ${set.setNumber}"),
                    subtitle: Text(
                      "${set.reps} reps @ ${set.weight}kg | ${set.notes ?? ''}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editSetDialog(set, index),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _addSet, child: const Text("Add Set")),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveWorkout,
              child: const Text("Save Workout"),
            ),
          ],
        ),
      ),
    );
  }
}
