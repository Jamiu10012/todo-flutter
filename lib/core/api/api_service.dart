import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_broom_app/core/features/tasks/models/task.dart';

class TaskApi {
  static const String baseUrl = "https://todo-golang-qm9j.onrender.com";
  // static const String baseUrl = "http://192.168.138.30:8080";

  // ---------------------------
  // GET categories
  // ---------------------------
  static Future<List<dynamic>> getCategories() async {
    final res = await http.get(Uri.parse("$baseUrl/categories"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load categories");
    }
  }

  // ---------------------------
  // CREATE task
  // ---------------------------
  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(taskData),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {"success": true};
    }

    try {
      final error = jsonDecode(res.body)["error"];
      return {"success": false, "message": error ?? "Unknown error"};
    } catch (_) {
      return {"success": false, "message": "Something went wrong"};
    }
  }

  // ---------------------------
  // GET tasks for specific day
  // ---------------------------
  static Future<List<dynamic>> getTasksForDate(String date) async {
    final res = await http.get(Uri.parse("$baseUrl/tasks?date=$date"));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  static Future<List<Task>> getTasks(String date) async {
    final res = await http.get(Uri.parse("$baseUrl/tasks?date=$date"));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data as List).map((e) => Task.fromJson(e)).toList();
    }

    throw Exception("Failed to load tasks");
  }
}
