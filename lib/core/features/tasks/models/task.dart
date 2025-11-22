class Task {
  final String id;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final String date;
  final String categoryId;
  final String categoryName;
  final bool completed;
  final bool highlighted;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.categoryId,
    required this.categoryName,
    required this.completed,
    required this.highlighted,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    startTime: json["startTime"],
    endTime: json["endTime"],
    date: json["date"],
    categoryId: json["categoryId"],
    categoryName: json["categoryName"],
    completed: json["completed"],
    highlighted: json["highlighted"],
  );
}
