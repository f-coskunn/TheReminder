import 'dart:developer';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:the_reminder/model/reminder_model.dart';
import 'package:the_reminder/model/task_model.dart';

class DatabaseHelper {
  static List<Task>? _tasks;
  static Database? _db;

  //Singleton yapısı
  static final DatabaseHelper instance = DatabaseHelper._();

  //Private Constructor
  DatabaseHelper._();

  Future<Database> get database async{
    //db == null ise get database() çağırıyor
    _db ??=await getDatabase();
    
    return _db!;
  }

  Future<List<Task>> get tasks async{
    
    return await _getTasks();

  }

  Future<Database> getDatabase() async{
    log("getting database");
    final dbdir = await getDatabasesPath();
    final dbpath = join(dbdir,"the_reminder_db.db");
    final db = await openDatabase(
      dbpath,
      version: 1,
      //Tablelar burada yaratılıyor ilk açılışta
      //TODO: user ekliyeceksek buradan ekliyeceğiz
      onCreate: (db,version){
        //Task table
        db.execute('''
          CREATE TABLE Task (
            taskID INTEGER PRIMARY KEY AUTOINCREMENT,
            
            title TEXT NOT NULL,
            description TEXT,
            dueDateTime TEXT NOT NULL,
            isCompleted INTEGER DEFAULT 0,
            priority TEXT
            );
          ''');
        //Reminder Table
        db.execute('''
          CREATE TABLE Reminder (
          reminderID INTEGER PRIMARY KEY AUTOINCREMENT,
          taskID INTEGER NOT NULL,
          reminderType TEXT,
          FOREIGN KEY (taskID) REFERENCES Task(taskID)
          );
          ''');
      }
    );
    log("done gettin db");
    return db;
  }

  Future<void> addTask(Task task) async{
    final db = await database;
    log("adding task");log(task.toString());
    //Task insert ediliyor
    int id = await db.insert("Task", task.toMap());
    log("adding task1.5");
    //Taska ait reminder varsa onları da insert et
    if(task.reminders.isNotEmpty){
      log("adding task2");
      for (var r in task.reminders) {

        //remindera taskın idsini veriyoruz
        r.taskID = id;
        log("adding task3");
        //Reminder insert ediliyor
        await db.insert("Reminder", r.toMap());
      }
    }
    
  }

  Future<void> deleteTask(int taskID) async{
    final db = await database;

    // Önce reminder'ları sil (foreign key constraint nedeniyle)
    await db.delete(
      'Reminder',
      where: 'taskID = ?',
      whereArgs: [taskID],
    );

    // Sonra task'ı sil
    await db.delete(
      'Task',
      where: 'taskID = ?',
      whereArgs: [taskID],
    );

    // Cache'deki listeyi güncelle
    _tasks?.removeWhere((t) => t.taskID == taskID);
  }

  //Bu metodla taskları almıyoruz. db.tasks ile taskları çağırıyoruz
  Future<List<Task>> _getTasks() async {
    log("getting tasks list");
    final db = await database;
    
    //Taskları databaseten getir
    final taskMaps = await db.query('Task');

    List<Task> tasks = [];
    log("getting tasks list 2");
    for (var taskMap in taskMaps) {
      log("getting tasks list loop");
      final task = Task.fromMap(taskMap);

      // İlgili taskID'ye ait reminder'ları al
      final reminderMaps = await db.query(
        'Reminder',
        where: 'taskID = ?',
        whereArgs: [task.taskID],
      );

      // Reminderları Task objesine ata
      task.reminders = reminderMaps.map((rMap) => Reminder.fromMap(rMap)).toList();

      tasks.add(task);
    }
    log("getting tasks list done");
    return tasks;
  }

  Future<List<Task>> getTaskOrderedByDueDate({bool ascending = true}) async {
    final db = await database;
    final order = ascending ? "ASC" : "DESC";

    final List<Map<String, dynamic>> maps = await db.query(
        'Task',
        orderBy: 'dueDateTime $order',
      
    );

     return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
  Future<List<Task>> getTasksOrderedByPriorityThenDueDate() async {
    final db = await database;
  
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM Task
      ORDER BY 
        CASE priority
          WHEN 'High' THEN 1
          WHEN 'Medium' THEN 2
          WHEN 'Low' THEN 3
          ELSE 4
        END,
        dueDateTime ASC
    ''');
  
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
}


}
