import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../services/session_service.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().fetchTodos();
      context.read<SessionService>().startTimer();
    });
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('NEW SECURE ENTRY', style: TextStyle(color: Color(0xFF00FF41), fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController, 
              decoration: const InputDecoration(labelText: 'ENTRY TITLE'),
              style: const TextStyle(color: Color(0xFF00FF41)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController, 
              decoration: const InputDecoration(labelText: 'ENCRYPTED PAYLOAD'),
              maxLines: 3,
              style: const TextStyle(color: Color(0xFF00FF41)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('ABORT', style: TextStyle(color: Colors.red))
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<TodoViewModel>().addTodo(titleController.text, noteController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => context.read<SessionService>().resetTimer(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'CIPHER_TASK.EXE',
            style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace', fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: Colors.red),
              onPressed: () {
                context.read<SessionService>().stopTimer();
                Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        ),
        body: Consumer<TodoViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.todos.isEmpty) {
              return const Center(
                child: Text(
                  'NO SECURE ENTRIES FOUND',
                  style: TextStyle(color: Color(0xFF004400), letterSpacing: 2),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.todos.length,
              itemBuilder: (context, index) {
                final todo = viewModel.todos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: Color(0xFF003300)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      todo.title.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF00FF41), fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text('DECRYPTED_NOTE:', style: TextStyle(color: Color(0xFF008F11), fontSize: 10)),
                        Text(
                          viewModel.decryptNote(todo.secretNote),
                          style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        todo.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: todo.isCompleted ? const Color(0xFF00FF41) : const Color(0xFF004400),
                      ),
                      onPressed: () => viewModel.toggleTodoStatus(todo),
                    ),
                    onLongPress: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('WIPING DATA...'),
                          action: SnackBarAction(
                            label: 'CONFIRM',
                            onPressed: () => viewModel.deleteTodo(todo.id!),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF00FF41),
          foregroundColor: Colors.black,
          onPressed: () => _showAddTodoDialog(context),
          child: const Icon(Icons.add_moderator),
        ),
      ),
    );
  }
}
