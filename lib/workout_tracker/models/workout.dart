class Exercise {
  final int id;
  final String name;
  final String? description;
  final DateTime createdDate;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    required this.createdDate,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdDate: DateTime.parse(json['created_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_date': createdDate.toIso8601String(),
    };
  }
}

class WorkoutSet {
  final int id;
  final Exercise exercise; // now a full Exercise object
  final int setNumber;
  final int reps;
  final double weight;
  final String? notes;
  final DateTime createdDate;

  WorkoutSet({
    required this.id,
    required this.exercise,
    required this.setNumber,
    required this.reps,
    required this.weight,
    this.notes,
    required this.createdDate,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'],
      exercise: Exercise(
        id: json['exercise'], // backend gives the ID
        name: json['exercise_name'], // backend gives the name
        description: null,
        createdDate:
            DateTime.now(), // placeholder, if needed can fetch full Exercise
      ),
      setNumber: json['set_number'],
      reps: json['reps'],
      weight: (json['weight'] as num).toDouble(),
      notes: json['notes'],
      createdDate: DateTime.parse(json['created_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise.id,
      'exercise_name': exercise.name,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'notes': notes,
      'created_date': createdDate.toIso8601String(),
    };
  }
}

class Workout {
  final int? id; // ✅ allow null for new workouts
  final String name;
  final String? notes;
  final DateTime createdDate;
  final List<WorkoutSet> sets;
  final int totalSets;

  Workout({
    this.id, 
    required this.name,
    this.notes,
    required this.createdDate,
    required this.sets,
    required this.totalSets,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'], // backend may send null or int
      name: json['name'],
      notes: json['notes'],
      createdDate: DateTime.parse(json['created_date']),
      sets: (json['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList(),
      totalSets: json['total_sets'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // ✅ only include if updating
      'name': name,
      'notes': notes,
      'created_date': createdDate.toIso8601String(),
      'sets': sets.map((s) => s.toJson()).toList(),
      'total_sets': totalSets,
    };
  }
}
