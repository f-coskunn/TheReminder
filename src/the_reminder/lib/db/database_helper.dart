import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/task_model.dart';

extension TaskOperations on DatabaseHelper {
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('Task', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Task');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'Task',
      task.toMap(),
      where: 'taskID = ?',
      whereArgs: [task.taskID],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'Task',
      where: 'taskID = ?',
      whereArgs: [id],
    );
  }
}


class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'thereminder.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        userID INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        profileID INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE AccessibilityProfile (
        profileID INTEGER PRIMARY KEY,
        userID INTEGER NOT NULL,
        defaultReminderType TEXT,
        screenReaderSupport INTEGER DEFAULT 0,
        highContrastEnabled INTEGER DEFAULT 0,
        fontSize INTEGER,
        FOREIGN KEY (userID) REFERENCES User(userID)
      );
    ''');

    await db.execute('''
      CREATE TABLE Task (
        taskID INTEGER PRIMARY KEY AUTOINCREMENT,
        userID INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        dueDateTime TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        priority TEXT,
        FOREIGN KEY (userID) REFERENCES User(userID)
      );
    ''');

    await db.execute('''
      CREATE TABLE Reminder (
        reminderID INTEGER PRIMARY KEY,
        taskID INTEGER NOT NULL,
        type TEXT CHECK(type IN ('audio', 'visual', 'vibration')),
        scheduledTime TEXT NOT NULL,
        FOREIGN KEY (taskID) REFERENCES Task(taskID)
      );
    ''');
  }
}
