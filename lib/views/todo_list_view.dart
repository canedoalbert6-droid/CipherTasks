import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../services/session_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().fetchTodos();
      context.read<SessionService>().startTimer();
    });
  }

  void _showDebugInfo(BuildContext context) async {
    final email = await _storage.read(key: AppConstants.userEmailKey);
    final rawTodos = context.read<TodoViewModel>().todos.map((t) => t.toMap()).toList();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: const Text('Developer Debug Info', style: TextStyle(color: AppTheme.primaryCyan)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Registered Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(email ?? 'No email found', style: const TextStyle(color: AppTheme.lightTextSecondary)),
                const SizedBox(height: 16),
                const Text('Raw Database Entries:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(rawTodos.toString(), style: TextStyle(color: AppTheme.lightTextSecondary, fontFamily: GoogleFonts.firaCode().fontFamily)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    }
  }

  void _showAddTodoBottomSheet(BuildContext context) {
    HapticFeedback.selectionClick(); 
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                    color: AppTheme.secondaryCyan,
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
                labelText: 'Secret Note / Password',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : AppTheme.lightTextSecondary;
    final textColor = isDark ? Colors.white : AppTheme.lightTextPrimary;

    return Listener(
      onPointerDown: (_) => context.read<SessionService>().resetTimer(),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let grid show through
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: _isSearching 
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : AppTheme.lightTextSecondary.withAlpha(128)),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  context.read<TodoViewModel>().setSearchQuery(value);
                },
              )
            : GestureDetector(
                onDoubleTap: () => _showDebugInfo(context),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: 1000.ms,
                  builder: (context, value, child) {
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'TheBid ',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w300,
                              color: textColor.withAlpha(180),
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text: 'CipherTask',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ).animate().shimmer(duration: 2000.ms, color: AppTheme.primaryCyan);
                  },
                ),
              ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, size: 20, color: iconColor),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchController.clear();
                    context.read<TodoViewModel>().setSearchQuery('');
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: iconColor),
              onSelected: (value) {
                if (value == 'select_all') {
                  context.read<TodoViewModel>().toggleAllStatus(true);
                } else if (value == 'deselect_all') {
                  context.read<TodoViewModel>().toggleAllStatus(false);
                } else if (value == 'delete_all') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(context).cardTheme.color,
                      title: Text('Wipe All Entries?', style: TextStyle(color: textColor)),
                      content: Text('This action cannot be undone.', style: TextStyle(color: isDark ? Colors.white70 : AppTheme.lightTextSecondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<TodoViewModel>().deleteAllTodos();
                            Navigator.pop(context);
                          },
                          child: const Text('WIPE ALL', style: TextStyle(color: AppTheme.errorRed)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'select_all', child: Text('Complete All')),
                const PopupMenuItem(value: 'deselect_all', child: Text('Uncomplete All')),
                const PopupMenuItem(value: 'delete_all', child: Text('Delete All', style: TextStyle(color: AppTheme.errorRed))),
              ],
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.circleUser, size: 20, color: iconColor),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<TodoViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.todos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryCyan.withAlpha(13),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(FontAwesomeIcons.vault, size: 80, color: AppTheme.secondaryCyan.withAlpha(128)),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .scale(duration: 1500.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05), curve: Curves.easeInOut),
                    const SizedBox(height: 32),
                    Text(
                      viewModel.searchQuery.isEmpty ? 'VAULT IS EMPTY' : 'NO RESULTS FOUND',
                      style: TextStyle(
                        color: textColor.withAlpha(179), 
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.searchQuery.isEmpty 
                        ? 'Tap + to create a secure entry'
                        : 'Try a different search term',
                      style: TextStyle(color: isDark ? Colors.white.withAlpha(102) : AppTheme.lightTextSecondary, fontSize: 14),
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
                final decryptedNote = viewModel.decryptNote(todo.secretNote);
                
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
                    ),
                    child: const Icon(FontAwesomeIcons.trashCan, color: AppTheme.errorRed, size: 28),
                  ),
                  onDismissed: (_) {
                    HapticFeedback.vibrate(); 
                    viewModel.deleteTodo(todo.id!);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withAlpha(todo.isCompleted ? 5 : 13) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: todo.isCompleted 
                          ? AppTheme.successGreen.withAlpha(26) 
                          : (isDark ? Colors.white.withAlpha(26) : AppTheme.lightBorder),
                        width: 1,
                      ),
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
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
                          HapticFeedback.mediumImpact(); 
                          viewModel.toggleTodoStatus(todo);
                        },
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
                                      : AppTheme.secondaryCyan.withAlpha(13),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: todo.isCompleted 
                                        ? AppTheme.successGreen.withAlpha(77) 
                                        : AppTheme.secondaryCyan.withAlpha(26),
                                  ),
                                ),
                                child: Center(
                                  child: todo.isCompleted 
                                    ? const Icon(FontAwesomeIcons.check, color: AppTheme.successGreen, size: 18)
                                    : Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.secondaryCyan,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.secondaryCyan,
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                       .scale(duration: 1000.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            todo.title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                                              color: todo.isCompleted 
                                                ? (isDark ? Colors.white38 : AppTheme.lightTextSecondary.withAlpha(128)) 
                                                : textColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          DateFormat('hh:mm a').format(todo.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.white.withAlpha(77) : AppTheme.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            decryptedNote,
                                            style: TextStyle(
                                              color: todo.isCompleted 
                                                ? (isDark ? Colors.white24 : AppTheme.lightTextSecondary.withAlpha(77)) 
                                                : (isDark ? Colors.white70 : AppTheme.lightTextSecondary),
                                              fontSize: 14,
                                              fontFamily: GoogleFonts.firaCode().fontFamily,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            FontAwesomeIcons.copy, 
                                            size: 14, 
                                            color: AppTheme.secondaryCyan.withAlpha(150)
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: decryptedNote));
                                            HapticFeedback.lightImpact();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Copied to clipboard'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTodoBottomSheet(context),
          backgroundColor: AppTheme.secondaryCyan,
          foregroundColor: Colors.white,
          icon: const Icon(FontAwesomeIcons.plus, size: 18),
          label: const Text('NEW ENTRY', style: TextStyle(fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
      ),
    );
  }
}
