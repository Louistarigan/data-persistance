class Task {
  int? id;
  String title;
  String description;
  int isDone; // 0 = false, 1 = true
  String createdAt;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isDone = 0,
    required this.createdAt,
  });

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String,
    isDone: map['isDone'] as int,
    createdAt: map['createdAt'] as String,
  );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
