import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminTaskLocationsPage extends StatefulWidget {
  const AdminTaskLocationsPage({super.key});

  @override
  State<AdminTaskLocationsPage> createState() => _AdminTaskLocationsPageState();
}

class _AdminTaskLocationsPageState extends State<AdminTaskLocationsPage> {
  bool loading = true;
  List<dynamic> locations = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final res = await http.get(
        Uri.parse("https://todo-golang-qm9j.onrender.com/admin/task-locations"),
      );

      if (res.statusCode == 200) {
        setState(() {
          locations = jsonDecode(res.body);
          loading = false;
        });
      }
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Locations (Admin)"),
        backgroundColor: const Color(0xFF4B4DED),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : locations.isEmpty
          ? const Center(child: Text("No location data"))
          : ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, i) {
                final item = locations[i];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text("Task: ${item['taskId']}"),
                  subtitle: Text(
                    "Lat: ${item['lat']}, Lng: ${item['lng']}\n"
                    "Time: ${item['time']}",
                  ),
                );
              },
            ),
    );
  }
}
