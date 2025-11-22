import 'package:flutter/material.dart';
import 'package:todo_broom_app/core/api/api_service.dart';
import 'package:todo_broom_app/core/features/tasks/view/create_detail_task_screen.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  int selectedDay = 0;

  List<Category> categories = [];
  bool isLoading = true;
  bool hasError = false;

  final List<String> days = [
    "5\nMon",
    "6\nTue",
    "7\nWed",
    "8\nThu",
    "9\nFri",
    "10\nSat",
  ];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final result = await TaskApi.getCategories();

      setState(() {
        categories = (result as List)
            .map((json) => Category.fromJson(json))
            .toList();

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 500;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F6),

      body: SafeArea(
        child: Column(
          children: [
            // --------------------------------------------
            // TOP HEADER BAR
            // --------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 24,
                      color: Colors.black87,
                    ),
                  ),

                  const Text(
                    "Create Task",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const Icon(
                    Icons.timer_outlined,
                    size: 26,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),

            // --------------------------------------------
            // FULL HEIGHT MIDDLE CONTENT
            // --------------------------------------------
            Expanded(
              child: Center(
                child: Container(
                  width: isWide ? 500 : double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      // --------------------------------------------
                      // DAY SELECTOR
                      // --------------------------------------------
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, i) {
                            bool active = selectedDay == i;

                            return GestureDetector(
                              onTap: () => setState(() => selectedDay = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 60,
                                decoration: BoxDecoration(
                                  color: active
                                      ? const Color(0xFF4B4DED)
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    days[i],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: active
                                          ? Colors.white
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemCount: days.length,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Choose activity",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------
                      // CATEGORY LIST
                      // --------------------------------------------
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Builder(
                            builder: (_) {
                              if (isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF4B4DED),
                                  ),
                                );
                              }

                              if (hasError) {
                                return const Center(
                                  child: Text(
                                    "Failed to load categories",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              return ListView(
                                children: [
                                  for (final c in categories)
                                    CategoryCard(
                                      category: c,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CreateTaskDetailsScreen(
                                                  category: c,
                                                  selectedDay: selectedDay,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // --------------------------------------------
      // FLOATING BUTTON
      // --------------------------------------------
      floatingActionButton: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF4B4DED),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
