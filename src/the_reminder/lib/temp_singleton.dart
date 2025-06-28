import 'package:the_reminder/model/task_model.dart';

class TaskSingleton {
  List<Task> _tasks;
  static final TaskSingleton _singleton = TaskSingleton._internal();
  
  factory TaskSingleton() {
    return _singleton;
  }
  
  TaskSingleton._internal()
        : _tasks = [
          Task(description: "Misafirler için balığı fırına at", reminder: "Pazartesi saat 8"),
          Task(description: "Spora git", reminder: "Cuma saat 6"),
          Task(description: "482 projesini yap", reminder: "Pazar saat 8"),
          Task(description: "Okula git", reminder: "Salı saat 2"),
          Task(description: "482 projesini yetiştir", reminder: "Pazartesi saat 12"),
          Task(description: "Otobüs bileti al", reminder: "Cuma saat 3"),
          Task(description: "Arkadaşlarla buluş", reminder: "Perşembe saat 10"),
        ];

  List<Task> get tasks =>_tasks;
  deleteTask(int i){
    _tasks.removeAt(i);
  }
  addTask(Task t){
    _tasks.add(t);
  }
}
/**
 =[
    Task(description: "Misafirler için balığı fırına at", reminder: "Pazartesi saat 8"),
    Task(description: "Spora git", reminder: "Cuma saat 6"),
    Task(description: "482 projesini yap", reminder: "Pazar saat 8"),
    Task(description: "Okula git", reminder: "Salı saat 2"),
    Task(description: "482 projesini yetiştir", reminder: "Pazartesi saat 12"),
    Task(description: "Otobüs bileti al", reminder: "Cuma saat 3"),
    Task(description: "Arkadaşlarla buluş", reminder: "Perşembe saat 10"),
  ]; 
 
 */