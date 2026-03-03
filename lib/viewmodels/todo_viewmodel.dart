import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';

class TodoViewModel extends ChangeNotifier {
  final DatabaseService _dbService;
  final EncryptionService _encryptionService;

  List<TodoModel> _todos = [];
  List<TodoModel> get todos => _todos;

  TodoViewModel(this._dbService, this._encryptionService);

  Future<void> fetchTodos() async {
    _todos = await _dbService.getTodos();
    notifyListeners();
  }

  Future<void> addTodo(String title, String secretNote) async {
    String encryptedNote = _encryptionService.encryptData(secretNote);
    TodoModel newTodo = TodoModel(title: title, secretNote: encryptedNote);
    await _dbService.insertTodo(newTodo);
    await fetchTodos();
  }

  Future<void> toggleTodoStatus(TodoModel todo) async {
    TodoModel updatedTodo = TodoModel(
      id: todo.id,
      title: todo.title,
      secretNote: todo.secretNote,
      isCompleted: !todo.isCompleted,
    );
    await _dbService.updateTodo(updatedTodo);
    await fetchTodos();
  }

  Future<void> deleteTodo(int id) async {
    await _dbService.deleteTodo(id);
    await fetchTodos();
  }

  String decryptNote(String encryptedNote) {
    try {
      return _encryptionService.decryptData(encryptedNote);
    } catch (e) {
      return "Decryption Error";
    }
  }
}
