import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminTaskLocationHistoryPage extends StatefulWidget {
  final String taskId;

  const AdminTaskLocationHistoryPage({super.key, required this.taskId});

  @override
  State<AdminTaskLocationHistoryPage> createState() =>
      _AdminTaskLocationHistoryPageState();
}

class _AdminTaskLocationHistoryPageState
    extends State<AdminTaskLocationHistoryPage> {
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
        Uri.parse(
          "http://localhost:8080/admin/tasks/${widget.taskId}/locations",
        ),
      );

      if (res.statusCode == 200) {
        setState(() {
          locations = jsonDecode(res.body);
          loading = false;
        });
      } else {
        loading = false;
      }
    } catch (_) {
      loading = false;
    }

    if (mounted) setState(() {});
  }

  String formatTime(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}  "
        "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Location History"),
        backgroundColor: const Color(0xFF4B4DED),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : locations.isEmpty
          ? const Center(child: Text("No location data found"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: locations.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final item = locations[index];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF4B4DED)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lat: ${item['lat']}, Lng: ${item['lng']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Time: ${formatTime(item['time'])}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Status: ${item['status']}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
