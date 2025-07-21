import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'observer.dart';
import 'subject.dart';
import '../model/task_model.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Concrete implementation of Subject for tasks
class TaskSubject implements Subject {
  final List<Observer> _observers = [];
  final Map<int, Timer> _timers = {};
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void attach(Observer observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
      log('Observer attached. Total observers: ${_observers.length}');
    }
  }

  @override
  void detach(Observer observer) {
    _observers.remove(observer);
    log('Observer detached. Total observers: ${_observers.length}');
  }

  @override
  void notify(String message, Map<String, dynamic> data) {
    log('Notifying ${_observers.length} observers with message: $message');
    for (Observer observer in _observers) {
      observer.update(message, data);
    }
  }

  // Schedule a task and notify observers when time comes
  void scheduleTask(Task task) async{
    try {
      final dueDateTime = DateTime.parse(task.dueDateTime);
      final taskId = task.taskID ?? 0;
      
      // Check if the time is in the past
      if (dueDateTime.isBefore(DateTime.now())) {
        log('Task time is in the past, skipping notification for: ${task.title}');
        // Don't notify for overdue tasks when rescheduling
        return;
      }
      
      final delay = dueDateTime.difference(DateTime.now());
      
      log('Scheduling task: ${task.title} at ${dueDateTime}');
      log('Delay: ${delay.inMinutes} minutes and ${delay.inSeconds % 60} seconds');
      log('Task ID: $taskId');
      
      // Cancel any existing timer for this task
      _timers[taskId]?.cancel();
      
      // Create a timer for the notification
      _timers[taskId] = Timer(delay, () {
        log('Timer fired for task: ${task.title}');
        notify('TASK_DUE', _createTaskData(task));
        _timers.remove(taskId);
      });

      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'scheduled title',
        'scheduled body',
        tz.TZDateTime.now(tz.local).add(delay),
        const NotificationDetails(
            android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            color: Colors.blue,
          )
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
      
      log('Task scheduled successfully. Active timers: ${_timers.length}');
      
    } catch (e) {
      log('Error scheduling task ${task.title}: $e');
      notify('TASK_ERROR', _createTaskData(task));
    }
  }

  // Cancel a scheduled task
  void cancelTask(int taskId) {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    log('Cancelled task: $taskId. Active timers: ${_timers.length}');
  }

  // Cancel all scheduled tasks
  void cancelAllTasks() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    log('Cancelled all tasks');
  }

  // Get active timer count (for debugging)
  int getActiveTimerCount() {
    return _timers.length;
  }

  // Handle overdue tasks (for manual triggering)
  void handleOverdueTask(Task task) {
    log('Manually handling overdue task: ${task.title}');
    notify('TASK_OVERDUE', _createTaskData(task));
  }

  // Create task data for observers
  Map<String, dynamic> _createTaskData(Task task) {
    return {
      'taskID': task.taskID,
      'title': task.title,
      'description': task.description,
      'dueDateTime': task.dueDateTime,
      'priority': task.priority.name,
      'isCompleted': task.isCompleted,
    };
  }

  // Dispose resources
  void dispose() {
    cancelAllTasks();
    _observers.clear();
    log('TaskSubject disposed');
  }
} 