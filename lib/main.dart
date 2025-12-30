import 'package:flutter/material.dart';
import 'package:todo_broom_app/core/features/tasks/view/admin_task_location_history_page.dart';
import 'package:todo_broom_app/core/features/tasks/view/admin_task_locations_page.dart';
import 'package:todo_broom_app/core/features/tasks/view/create_task_screen.dart';
import 'package:todo_broom_app/core/features/tasks/view/task_confirm_page.dart';
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

      //  USE onGenerateRoute
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        if (uri.path == '/task-confirm') {
          return MaterialPageRoute(
            builder: (_) => const TaskConfirmPage(),
            settings: settings,
          );
        }

        if (uri.path == '/create') {
          return MaterialPageRoute(builder: (_) => const CreateTaskScreen());
        }

        if (uri.path == '/admin/locations') {
          return MaterialPageRoute(
            builder: (_) => const AdminTaskLocationsPage(),
          );
        }
        if (uri.path == '/admin/task-locations') {
          final taskId = uri.queryParameters['taskId'];
          if (taskId == null) {
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text("Missing taskId"))),
            );
          }

          return MaterialPageRoute(
            builder: (_) => AdminTaskLocationHistoryPage(taskId: taskId),
          );
        }

        // default → home
        return MaterialPageRoute(builder: (_) => const TodayScreen());
      },
    );
  }
}
