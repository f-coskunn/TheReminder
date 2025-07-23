
import 'dart:developer';

import 'package:the_reminder/model/reminder_model.dart';


enum Priority { High, Medium, Low }

enum NotificationType { Vibration, Visual, Audio }

class Task {
  int? taskID;
  String title;
  String description;
  // TODO dueDateTime DateTime'a çevrilebilir
  String dueDateTime;
  bool isCompleted;
  Priority priority;
  List<Reminder> reminders;
  List<NotificationType> notificationTypes; // Changed to support multiple types

Task({
    this.taskID,
    required this.title,
    this.description="",
    required this.dueDateTime,
    this.isCompleted = false,
    this.priority = Priority.Medium,
    this.reminders = const [],
    this.notificationTypes = const [NotificationType.Visual], // Default to visual only
  });  


  Map<String, dynamic> toMap() {
    return {
      'taskID': taskID,
      'title': title,
      'description': description,
      'dueDateTime': dueDateTime,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': _priorityToString(priority),
      'notificationTypes': _notificationTypesToString(notificationTypes),
    };
  }


  //Reminder dışarda yaratılıp atancak
   factory Task.fromMap(Map<String, dynamic> map) {
    log(map['priority']);
    return Task(
      taskID: map['taskID'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDateTime: map['dueDateTime'],
      isCompleted: map['isCompleted'] == 1,
      priority: _priorityFromString(map['priority'] ?? 'Medium'),
      reminders: [],
      notificationTypes: _notificationTypesFromString(map['notificationTypes'] ?? 'Visual'),
    );
  }
  set setCompleted(bool c)=>isCompleted=c;


  @override
  String toString() {
    return "Description:$description\nReminder:${reminders.toString()}\nCompleted:$isCompleted\nNotificationTypes:${notificationTypes.map((t) => t.name).join(', ')}";
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

  // Converts notification types list to string
  String _notificationTypesToString(List<NotificationType> types) {
    return types.map((type) => type.name).join(',');
  }

  // Converts string to notification types list
  static List<NotificationType> _notificationTypesFromString(String s) {
    if (s.isEmpty) return [NotificationType.Visual]; // Default to visual
    
    final typeStrings = s.split(',');
    final types = <NotificationType>[];
    
    for (final typeString in typeStrings) {
      switch (typeString.trim().toLowerCase()) {
        case 'vibration':
          types.add(NotificationType.Vibration);
          break;
        case 'visual':
          types.add(NotificationType.Visual);
          break;
        case 'audio':
          types.add(NotificationType.Audio);
          break;
      }
    }
    
    // Always ensure visual is included
    if (!types.contains(NotificationType.Visual)) {
      types.add(NotificationType.Visual);
    }
    
    return types;
  }
}
