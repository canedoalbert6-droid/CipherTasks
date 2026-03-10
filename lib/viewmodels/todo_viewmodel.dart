import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';

class TodoViewModel extends ChangeNotifier {
  final DatabaseService _dbService;
  final EncryptionService _encryptionService;

  List<TodoModel> _allTodos = [];
  List<TodoModel> _filteredTodos = [];
  String _searchQuery = '';

  List<TodoModel> get todos => _filteredTodos;
  String get searchQuery => _searchQuery;

  TodoViewModel(this._dbService, this._encryptionService);

  Future<void> fetchTodos() async {
    print('DEBUG: Fetching todos from database service...');
    _allTodos = await _dbService.getTodos();
    _applySearch();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredTodos = List.from(_allTodos);
    } else {
      _filteredTodos = _allTodos.where((todo) {
        final decryptedNote = decryptNote(todo.secretNote).toLowerCase();
        return todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               decryptedNote.contains(_searchQuery.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> addTodo(String title, String secretNote) async {
    print('DEBUG: Preparing to add new todo...');
    print('DEBUG: Raw secret note: $secretNote');
    String encryptedNote = _encryptionService.encryptData(secretNote);
    print('DEBUG: Encrypted note for storage: $encryptedNote');
    
    TodoModel newTodo = TodoModel(title: title, secretNote: encryptedNote);
    await _dbService.insertTodo(newTodo);
    await fetchTodos();
  }

  Future<void> toggleTodoStatus(TodoModel todo) async {
    print('DEBUG: Toggling status for ID ${todo.id}');
    TodoModel updatedTodo = TodoModel(
      id: todo.id,
      title: todo.title,
      secretNote: todo.secretNote,
      isCompleted: !todo.isCompleted,
      createdAt: todo.createdAt,
    );
    await _dbService.updateTodo(updatedTodo);
    await fetchTodos();
  }

  Future<void> toggleAllStatus(bool isCompleted) async {
    print('DEBUG: Toggling ALL status to: $isCompleted');
    for (var todo in _allTodos) {
      if (todo.isCompleted != isCompleted) {
        TodoModel updatedTodo = TodoModel(
          id: todo.id,
          title: todo.title,
          secretNote: todo.secretNote,
          isCompleted: isCompleted,
          createdAt: todo.createdAt,
        );
        await _dbService.updateTodo(updatedTodo);
      }
    }
    await fetchTodos();
  }

  Future<void> deleteTodo(int id) async {
    print('DEBUG: Deleting todo ID $id');
    await _dbService.deleteTodo(id);
    await fetchTodos();
  }

  Future<void> deleteAllTodos() async {
    print('DEBUG: Wiping all todos from database...');
    await _dbService.deleteAllTodos();
    await fetchTodos();
  }

  String decryptNote(String encryptedNote) {
    try {
      final decrypted = _encryptionService.decryptData(encryptedNote);
      // print('DEBUG: Decrypting $encryptedNote -> $decrypted'); // Optional: very verbose
      return decrypted;
    } catch (e) {
      print('DEBUG: Decryption Error for data: $encryptedNote');
      return "Decryption Error";
    }
  }
}
