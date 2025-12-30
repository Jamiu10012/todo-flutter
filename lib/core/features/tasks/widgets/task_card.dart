import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/task.dart';

/// --------------------
/// TIME HELPERS
/// --------------------
Duration parseDuration(String start, String end) {
  final s = start.split(":");
  final e = end.split(":");

  final startMinutes = int.parse(s[0]) * 60 + int.parse(s[1]);
  final endMinutes = int.parse(e[0]) * 60 + int.parse(e[1]);

  return Duration(minutes: endMinutes - startMinutes);
}

String formatDuration(Duration d) {
  if (d.inHours > 0 && d.inMinutes % 60 == 0) {
    return "${d.inHours} hour";
  } else if (d.inHours > 0) {
    return "${d.inHours} hour ${d.inMinutes % 60} mins";
  } else {
    return "${d.inMinutes} mins";
  }
}

bool isNowActive(String date, String start, String end) {
  try {
    final startDT = DateTime.parse("$date $start:00");
    final endDT = DateTime.parse("$date $end:00");
    final now = DateTime.now();
    return now.isAfter(startDT) && now.isBefore(endDT);
  } catch (_) {
    return false;
  }
}

/// --------------------
/// PHONE NORMALIZER (NIGERIA)
/// --------------------
String normalizeNigerianNumber(String input) {
  var phone = input.trim();

  // remove spaces
  phone = phone.replaceAll(RegExp(r'\s+'), '');

  // remove leading 0 (080 -> 80)
  if (phone.startsWith('0')) {
    phone = phone.substring(1);
  }

  // WhatsApp-safe (NO +)
  return '234$phone';
}

/// --------------------
/// WHATSAPP SENDER
/// --------------------
Future<void> sendTaskToWhatsApp({
  required String phone,
  required Task task,
}) async {
  final message =
      '''
Task: ${task.title}
Date: ${task.date}
Time: ${task.startTime} - ${task.endTime}

Please confirm this task:

🟢 ACCEPT
https://todo-flutter-red.vercel.app/#/task-confirm?taskId=${task.id}&action=accept

🔴 REJECT
https://todo-flutter-red.vercel.app/#/task-confirm?taskId=${task.id}&action=reject
''';

  final uri = Uri.parse(
    "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
  );

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// --------------------
/// TASK CARD
/// --------------------
class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late bool localCompleted;

  @override
  void initState() {
    super.initState();
    localCompleted = widget.task.completed;
  }

  /// --------------------
  /// SEND MODAL
  /// --------------------
  void _showSendModal(BuildContext context) {
    final controller = TextEditingController();
    bool isValid = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Send Task via WhatsApp",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  /// PHONE INPUT (+234)
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone number",
                      hintText: "8012345678",
                      prefixText: "+234 ",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      setModalState(() {
                        // Nigerian local numbers: 9–10 digits
                        isValid = RegExp(r'^[0-9]{9,10}$').hasMatch(v);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () async {
                              Navigator.pop(ctx);

                              final phone = normalizeNigerianNumber(
                                controller.text,
                              );

                              await sendTaskToWhatsApp(
                                phone: phone,
                                task: widget.task,
                              );
                            }
                          : null,
                      child: const Text("Proceed"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// --------------------
  /// UI
  /// --------------------
  @override
  Widget build(BuildContext context) {
    final isSelected =
        widget.task.highlighted ||
        isNowActive(
          widget.task.date,
          widget.task.startTime,
          widget.task.endTime,
        );

    final duration = parseDuration(widget.task.startTime, widget.task.endTime);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 30,
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              localCompleted ? "Completed" : formatDuration(duration),
              style: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4B4DED) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Checkbox(
                  value: localCompleted,
                  onChanged: (_) {
                    setState(() => localCompleted = !localCompleted);
                  },
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.task.startTime} - ${widget.task.endTime}",
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: isSelected ? Colors.white : const Color(0xFF4B4DED),
                  ),
                  onPressed: () => _showSendModal(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
