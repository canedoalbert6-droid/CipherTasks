import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';

class DatabaseService {
  Database? _database;
  final String dbKey;

  DatabaseService(this.dbKey);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'ciphertask.db');
    print('DEBUG: Initializing database at: $path');
    return await openDatabase(
      path,
      password: dbKey,
      version: 2,
      onCreate: (db, version) async {
        print('DEBUG: Creating database table "todos"');
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            secretNote TEXT,
            isCompleted INTEGER,
            createdAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('DEBUG: Upgrading database from $oldVersion to $newVersion');
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE todos ADD COLUMN createdAt TEXT');
        }
      },
    );
  }

  Future<void> insertTodo(TodoModel todo) async {
    final db = await database;
    final map = todo.toMap();
    print('DEBUG: Inserting into SQLite: $map');
    await db.insert('todos', map);
  }

  Future<List<TodoModel>> getTodos() async {
    final db = await database;
    print('DEBUG: Fetching all entries from SQLite...');
    final List<Map<String, dynamic>> maps = await db.query('todos', orderBy: 'createdAt DESC');
    
    print('DEBUG: Raw SQLite results count: ${maps.length}');
    for (var map in maps) {
      print('DEBUG: Row data: $map');
    }

    return List.generate(maps.length, (i) {
      return TodoModel.fromMap(maps[i]);
    });
  }

  Future<void> updateTodo(TodoModel todo) async {
    final db = await database;
    final map = todo.toMap();
    print('DEBUG: Updating SQLite ID ${todo.id}: $map');
    await db.update(
      'todos',
      map,
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final db = await database;
    print('DEBUG: Deleting SQLite ID: $id');
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllTodos() async {
    final db = await database;
    print('DEBUG: Wiping ALL entries from SQLite');
    await db.delete('todos');
  }
}
