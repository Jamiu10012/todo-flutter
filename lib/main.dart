import 'package:flutter/material.dart';
import 'package:todo_broom_app/core/features/tasks/view/create_task_screen.dart';
import 'package:todo_broom_app/core/features/tasks/view/today_screen.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo UI",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        useMaterial3: true,
      ),
      home: TodayScreen(),
      routes: {"/create": (_) => CreateTaskScreen()},
    );
  }
}
