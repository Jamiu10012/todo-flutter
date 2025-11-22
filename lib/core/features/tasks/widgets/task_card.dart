import 'package:flutter/material.dart';
import '../models/task.dart';

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
    // Build DateTime from parts
    final startDT = DateTime.parse("$date $start:00");
    final endDT = DateTime.parse("$date $end:00");
    final now = DateTime.now();

    return now.isAfter(startDT) && now.isBefore(endDT);
  } catch (e) {
    return false;
  }
}


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

  @override
  Widget build(BuildContext context) {
    final bool isSelected =
        widget.task.highlighted ||
        isNowActive(
          widget.task.date,
          widget.task.startTime,
          widget.task.endTime,
        );

    // Build time string
    final timeText = "${widget.task.startTime} - ${widget.task.endTime}";

    // Duration
    final duration = parseDuration(widget.task.startTime, widget.task.endTime);
    final durationText = formatDuration(duration);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // LEFT LABEL
        SizedBox(
          width: 30,
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              localCompleted ? "Completed" : durationText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // MAIN CARD
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4B4DED) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 25,
                        offset: Offset(0, 10),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // CHECKBOX
                GestureDetector(
                  onTap: () {
                    setState(() {
                      localCompleted = !localCompleted;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: localCompleted
                          ? (isSelected ? Colors.white : Colors.indigo)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 2,
                        color: localCompleted
                            ? Colors.transparent
                            : (isSelected
                                  ? Colors.white
                                  : Colors.grey.shade400),
                      ),
                    ),
                    child: localCompleted
                        ? Icon(
                            Icons.check,
                            size: 22,
                            color: isSelected
                                ? const Color(0xFF4B4DED)
                                : Colors.white,
                          )
                        : Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4B4DED),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 20),

                // TEXTS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeText,
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // RIGHT LABEL
        SizedBox(
          width: 30,
          child: Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                localCompleted ? "" : durationText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
