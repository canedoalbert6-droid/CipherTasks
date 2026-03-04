import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for HapticFeedback
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../viewmodels/todo_viewmodel.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';

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

  void _showAddTodoBottomSheet(BuildContext context) {
    HapticFeedback.selectionClick(); // Sensory feedback when opening sheet
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Secure Entry',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryCyan,
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(FontAwesomeIcons.tag, size: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Secret Note',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(FontAwesomeIcons.lock, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    context.read<TodoViewModel>().addTodo(titleController.text, noteController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('ENCRYPT & SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => context.read<SessionService>().resetTimer(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: 1000.ms,
            builder: (context, value, child) {
              return Text(
                'TheBid CipherTask',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ).animate().shimmer(duration: 2000.ms, color: AppTheme.primaryCyan);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.rightFromBracket, size: 20, color: Colors.white70),
              onPressed: () {
                context.read<SessionService>().stopTimer();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.backgroundDark, Color(0xFF1E293B)],
            ),
          ),
          child: Consumer<TodoViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.todos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withAlpha(13),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesomeIcons.vault, size: 80, color: AppTheme.primaryCyan.withAlpha(128)),
                      ).animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack)
                        .then()
                        .shimmer(duration: 2000.ms, color: AppTheme.primaryCyan.withAlpha(51)),
                      const SizedBox(height: 32),
                      Text(
                        'VAULT IS EMPTY',
                        style: TextStyle(
                          color: Colors.white.withAlpha(179), 
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to create a secure entry',
                        style: TextStyle(color: Colors.white.withAlpha(102), fontSize: 14),
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
                itemCount: viewModel.todos.length,
                itemBuilder: (context, index) {
                  final todo = viewModel.todos[index];
                  return Dismissible(
                    key: Key(todo.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withAlpha(51),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.errorRed.withAlpha(102), width: 1),
                      ),
                      child: const Icon(FontAwesomeIcons.trashCan, color: AppTheme.errorRed, size: 28),
                    ),
                    onDismissed: (_) {
                      HapticFeedback.vibrate(); // Heavy sensory feedback for deletion
                      viewModel.deleteTodo(todo.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Secure entry wiped.')),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(todo.isCompleted ? 5 : 13), // Glass effect
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: todo.isCompleted 
                            ? AppTheme.successGreen.withAlpha(26) 
                            : Colors.white.withAlpha(26),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            HapticFeedback.mediumImpact(); // Sensory feedback when toggling
                            viewModel.toggleTodoStatus(todo);
                          },
                          splashColor: AppTheme.primaryCyan.withAlpha(26),
                          highlightColor: AppTheme.primaryCyan.withAlpha(13),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: todo.isCompleted 
                                        ? AppTheme.successGreen.withAlpha(26) 
                                        : AppTheme.primaryCyan.withAlpha(26),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: todo.isCompleted 
                                          ? AppTheme.successGreen.withAlpha(77) 
                                          : AppTheme.primaryCyan.withAlpha(77),
                                    ),
                                  ),
                                  child: Icon(
                                    todo.isCompleted ? FontAwesomeIcons.check : FontAwesomeIcons.lock,
                                    color: todo.isCompleted ? AppTheme.successGreen : AppTheme.primaryCyan,
                                    size: 20,
                                  ),
                                ).animate(target: todo.isCompleted ? 1 : 0)
                                 .shimmer(duration: 500.ms),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                          color: todo.isCompleted ? Colors.white38 : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        viewModel.decryptNote(todo.secretNote),
                                        style: TextStyle(
                                          color: todo.isCompleted ? Colors.white24 : Colors.white70,
                                          fontSize: 14,
                                          fontFamily: GoogleFonts.firaCode().fontFamily,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryCyan.withAlpha(77),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddTodoBottomSheet(context),
            backgroundColor: AppTheme.primaryCyan,
            foregroundColor: Colors.black,
            icon: const Icon(FontAwesomeIcons.plus, size: 18),
            label: const Text('NEW ENTRY', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
