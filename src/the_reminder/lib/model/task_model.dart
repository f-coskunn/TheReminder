
import 'dart:developer';

import 'package:the_reminder/model/reminder_model.dart';


enum Priority { High, Medium, Low }


class Task {
  int? taskID;
  String title;
  String description;
  // TODO dueDateTime DateTime'a çevrilebilir
  String dueDateTime;
  bool isCompleted;
  Priority priority;
  List<Reminder> reminders;

Task({
    this.taskID,
    required this.title,
    this.description="",
    required this.dueDateTime,
    this.isCompleted = false,
    this.priority = Priority.Medium,
    this.reminders = const [],
  });  


  Map<String, dynamic> toMap() {
    return {
      'taskID': taskID,
      'title': title,
      'description': description,
      'dueDateTime': dueDateTime,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': _priorityToString(priority),
    };
  }


  //Reminder dışarda yaratılıp atancak
   factory Task.fromMap(Map<String, dynamic> map) {
    log(map['priority']);
    log("up/////////////////////////////////////////////////////////");
    return Task(
      taskID: map['taskID'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDateTime: map['dueDateTime'],
      isCompleted: map['isCompleted'] == 1,
      priority: _priorityFromString(map['priority'] ?? 'Medium'),
      reminders: [],
    );
  }
  set setCompleted(bool c)=>isCompleted=c;


  @override
  String toString() {
    return "Description:$description\nReminder:${reminders.toString()}\nCompleted:$isCompleted";
  }

  // Converts enum to string
  String _priorityToString(Priority p) => p.name.toString();


  // Converts string to enum
  static Priority _priorityFromString(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return Priority.High;
      case 'low':
        return Priority.Low;
      default:
        return Priority.Medium;
    }
  }
}
