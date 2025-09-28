import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout.dart';

const String baseUrl = "http://134.209.155.105:8000/api/workout_tracker";

class ApiService {
  // Fetch all workouts
  static Future<List<Workout>> fetchWorkouts() async {
    final response = await http.get(Uri.parse("$baseUrl/workouts/"));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Workout.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch workouts");
    }
  }

  static Future<Workout> saveWorkout(Workout workout) async {
    final url = workout.id == null
        ? Uri.parse("$baseUrl/workouts/")
        : Uri.parse("$baseUrl/workouts/${workout.id}/");

    final response = await (workout.id == null
        ? http.post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(workout.toJson()),
          )
        : http.put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(workout.toJson()),
          ));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonBody = jsonDecode(response.body);
      return Workout.fromJson(jsonBody); // capture backend ID
    } else {
      throw Exception("Failed to save workout");
    }
  }

  // Delete workout
  static Future<void> deleteWorkout(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/workouts/$id/"));
    if (response.statusCode != 204) {
      throw Exception("Failed to delete workout");
    }
  }

  // Copy previous workout from date
  static Future<void> copyWorkoutFromDate(DateTime date) async {
    final response = await http.post(
      Uri.parse("$baseUrl/workouts/copy/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"date": date.toIso8601String()}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to copy workout");
    }
  }
}
