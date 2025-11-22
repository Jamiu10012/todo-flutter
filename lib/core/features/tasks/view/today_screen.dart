import 'package:flutter/material.dart';
import 'package:todo_broom_app/core/api/api_service.dart';
import 'package:todo_broom_app/core/features/tasks/view/create_task_screen.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> dateInfo = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadWeek();
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      case DateTime.sunday:
        return "Sun";
      default:
        return "";
    }
  }

  String _monthLabel(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month];
  }

  int _computeDurationMinutes(String start, String end) {
    final s = start.split(":");
    final e = end.split(":");
    final startMin = int.parse(s[0]) * 60 + int.parse(s[1]);
    final endMin = int.parse(e[0]) * 60 + int.parse(e[1]);
    return (endMin - startMin).clamp(0, 9999);
  }

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return "0 hours";
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return "$h hours a day";
    if (h == 0) return "$m mins a day";
    return "${h}h ${m}m a day";
  }

  Future<void> _loadWeek() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<Map<String, dynamic>> tmp = [];

    try {
      for (int i = 0; i < 7; i++) {
        final d = today.add(Duration(days: i));
        final dateStr =
            "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

        final raw = await TaskApi.getTasksForDate(dateStr);

        final tasks = (raw as List)
            .map((j) => Task.fromJson(j as Map<String, dynamic>))
            .toList();

        int totalMinutes = 0;
        for (final t in tasks) {
          totalMinutes += _computeDurationMinutes(t.startTime, t.endTime);
        }

        tmp.add({
          "date": dateStr,
          "day": d.day.toString(),
          "label": _weekdayLabel(d.weekday),
          "hours": _formatMinutes(totalMinutes),
          "tasks": tasks,
        });
      }

      setState(() {
        dateInfo = tmp;
        isLoading = false;
        hasError = false;
        selectedIndex = 0;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Widget buildDateCard({
    required String day,
    required String label,
    required bool selected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF4B4DED) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: selected
            ? []
            : [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white70 : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 500;

    final today = DateTime.now();
    final headerDate = "${today.day} ${_monthLabel(today.month)}";

    List<Task> tasksForSelected = [];
    if (!isLoading &&
        !hasError &&
        dateInfo.isNotEmpty &&
        selectedIndex < dateInfo.length) {
      tasksForSelected = dateInfo[selectedIndex]["tasks"] as List<Task>;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 248),
      body: SafeArea(
        child: Center(
          child: Container(
            width: isWide ? 500 : double.infinity,
            color: const Color(0xFF4B4DED),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      // Center aligned header icons + date
                      SizedBox(
                        height: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(Icons.grid_view,
                                  color: Colors.white, size: 28),
                            ),
                            Text(
                              headerDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.schedule,
                                  color: Colors.white, size: 26),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Today + Add New
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${tasksForSelected.length} tasks",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          GestureDetector(
                            onTap: () async {
                              final created = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateTaskScreen(),
                                ),
                              );

                              if (created == true) {
                                _loadWeek();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                "Add New",
                                style: TextStyle(
                                  color: Color(0xFF4B4DED),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // WHITE AREA
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          height: 120,
                          child: isLoading && dateInfo.isEmpty
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(color: Colors.grey),
                                )
                              : hasError && dateInfo.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "Failed to load days",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: dateInfo.length,
                                      itemBuilder: (context, index) {
                                        final item = dateInfo[index];
                                        final selected =
                                            selectedIndex == index;

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() =>
                                                selectedIndex = index);
                                          },
                                          child: Row(
                                            children: [
                                              buildDateCard(
                                                day: item["day"],
                                                label: item["label"],
                                                selected: selected,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                item["hours"],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 170),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // TASK LIST
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      child: Builder(builder: (_) {
                        if (isLoading && dateInfo.isNotEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (hasError) {
                          return const Center(
                            child: Text(
                              "Failed to load tasks",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        if (tasksForSelected.isEmpty) {
                          return const Center(
                            child: Text("No tasks for this day"),
                          );
                        }

                        return ListView(
                          children: [
                            for (final t in tasksForSelected)
                              TaskCard(task: t),
                          ],
                        );
                      }),
                    ),
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
