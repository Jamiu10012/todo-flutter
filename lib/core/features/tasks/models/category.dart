class Category {
  final String id;
  final String name;
  final String icon;
  final int count;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      name: json['name'],
      icon: json['icon'],
      count: json['weeklyCount'] ?? json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "icon": icon, "count": count};
  }
}
