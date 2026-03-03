class TodoModel {
  final int? id;
  final String title;
  final String secretNote; // This will be encrypted
  final bool isCompleted;

  TodoModel({
    this.id,
    required this.title,
    required this.secretNote,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'secretNote': secretNote,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'],
      title: map['title'],
      secretNote: map['secretNote'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
