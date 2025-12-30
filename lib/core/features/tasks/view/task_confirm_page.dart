import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TaskConfirmPage extends StatefulWidget {
  const TaskConfirmPage({super.key});

  @override
  State<TaskConfirmPage> createState() => _TaskConfirmPageState();
}

class _TaskConfirmPageState extends State<TaskConfirmPage> {
  bool loading = false;
  bool accepted = false;
  Timer? locationTimer;

  late String taskId;
  late String action;

  // static const backendBaseUrl = "http://localhost:8080";
  static const String backendBaseUrl = "https://todo-golang-qm9j.onrender.com";

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final routeName = ModalRoute.of(context)?.settings.name;

    if (routeName == null) {
      taskId = '';
      action = '';
      return;
    }

    final uri = Uri.parse(routeName);

    taskId = uri.queryParameters['taskId'] ?? '';
    action = uri.queryParameters['action'] ?? '';

    debugPrint("TASK ID = $taskId");
    debugPrint("ACTION = $action");

    if (taskId.isEmpty) return;

    if (action == 'reject') {
      _sendDecision(rejected: true);
    }
  }


  /// ------------------------------------------------
  /// LOCATION PERMISSION + FETCH
  /// ------------------------------------------------
  Future<Position?> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// ------------------------------------------------
  /// SEND TO BACKEND
  /// ------------------------------------------------
  Future<void> _sendDecision({
    bool rejected = false,
    double? lat,
    double? lng,
  }) async {
    try {
      await http.post(
        Uri.parse("$backendBaseUrl/tasks/$taskId/confirm"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "status": rejected ? "rejected" : "accepted",
          "lat": lat,
          "lng": lng,
        }),
      );
    } catch (e) {
      debugPrint("Failed to send decision: $e");
    }
  }

  /// ------------------------------------------------
  /// AUTO LOCATION UPDATE EVERY 10 MINUTES
  /// ------------------------------------------------
  Future<void> startAutoLocationUpdates() async {
    if (accepted) return;

    setState(() {
      accepted = true;
      loading = true;
    });

    final firstPos = await _getLocation();
    if (firstPos == null) {
      setState(() => loading = false);
      return;
    }

    await _sendDecision(lat: firstPos.latitude, lng: firstPos.longitude);

    setState(() => loading = false);

    locationTimer = Timer.periodic(const Duration(minutes: 10), (_) async {
      final pos = await _getLocation();
      if (pos == null) return;

      await _sendDecision(lat: pos.latitude, lng: pos.longitude);
    });
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  /// ------------------------------------------------
  /// UI
  /// ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // REJECT VIEW
    if (action == 'reject') {
      return const Scaffold(
        body: Center(
          child: Text("Task Rejected", style: TextStyle(fontSize: 20)),
        ),
      );
    }

    // ACCEPT VIEW
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Confirm Task",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B4DED),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 60,
                      color: Color(0xFF4B4DED),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "We need your location to confirm and track this task.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B4DED),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: accepted
                          ? null
                          : () async {
                              final pos = await _getLocation();

                              if (pos == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Location permission is required",
                                    ),
                                  ),
                                );
                                return;
                              }

                              await startAutoLocationUpdates();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "✅ Task accepted. Location updates every 10 minutes.",
                                    ),
                                  ),
                                );
                              }
                            },
                      child: const Text(
                        "Accept & Share Location",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
