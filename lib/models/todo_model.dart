class TodoModel {
  final int? id;
  final String title;
  final String secretNote; // This will be encrypted
  final bool isCompleted;
  final DateTime createdAt;

  TodoModel({
    this.id,
    required this.title,
    required this.secretNote,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'secretNote': secretNote,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      secretNote: map['secretNote'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
