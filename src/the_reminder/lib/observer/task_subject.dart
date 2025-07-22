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
  bool _isInitialized = false;

  // Initialize the task subject
  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC')); // Use UTC as fallback
      
      // Initialize notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await flutterLocalNotificationsPlugin.initialize(initSettings);
      
      // Create notification channels
      await _createNotificationChannels();
      
      _isInitialized = true;
      log('TaskSubject initialized successfully');
    } catch (e) {
      log('Error initializing TaskSubject: $e');
      // Don't rethrow, just log the error
    }
  }

  // Create notification channels
  Future<void> _createNotificationChannels() async {
    try {
      // Audio channel
      const audioChannel = AndroidNotificationChannel(
        'task_reminders_audio',
        'Task Reminders (Audio)',
        description: 'Notifications with sound for task reminders',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Silent channel
      const silentChannel = AndroidNotificationChannel(
        'task_reminders_silent',
        'Task Reminders (Silent)',
        description: 'Silent notifications for task reminders',
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(audioChannel);
          
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(silentChannel);
          
      log('Notification channels created successfully');
    } catch (e) {
      log('Error creating notification channels: $e');
    }
  }

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
  void scheduleTask(Task task) async {
    try {
      // Ensure initialization
      await _initialize();
      
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

      // Schedule background notification
      final notificationDetails = _createNotificationDetails(task);
      final notificationTypes = task.notificationTypes.map((t) => t.name).join(', ');
      
      log('Scheduling background notification for task: ${task.title}');
      log('Notification types: $notificationTypes');
      log('Sound enabled: ${task.notificationTypes.contains(NotificationType.Audio)}');
      log('Vibration enabled: ${task.notificationTypes.contains(NotificationType.Vibration)}');
      
      // Use a safer approach for scheduling
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        taskId,
        task.title ?? 'Task Reminder',
        task.description ?? 'You have a task due.',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      log('Task scheduled successfully. Active timers: ${_timers.length}');
      
    } catch (e) {
      log('Error scheduling task ${task.title}: $e');
      // Don't trigger error notification for scheduling issues
      // Just log the error and continue
    }
  }

  // Cancel a scheduled task
  void cancelTask(int taskId) async{
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    
    // Also cancel the scheduled notification
    await flutterLocalNotificationsPlugin.cancel(taskId);
    
    log('Cancelled task: $taskId. Active timers: ${_timers.length}');
  }

  // Cancel all scheduled tasks
  void cancelAllTasks() async{
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    
    // Cancel all scheduled notifications
    await flutterLocalNotificationsPlugin.cancelAll();
    
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

  // Manually trigger a task notification (for testing)
  void triggerTaskNotification(Task task) {
    log('Manually triggering notification for task: ${task.title}');
    notify('TASK_DUE', _createTaskData(task));
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
      'notificationTypes': task.notificationTypes.map((t) => t.name).toList(),
    };
  }

  // Create notification details based on task's notification types
  NotificationDetails _createNotificationDetails(Task task) {
    bool enableVibration = task.notificationTypes.contains(NotificationType.Vibration);
    bool playSound = task.notificationTypes.contains(NotificationType.Audio);
    
    // Use different channels based on notification types
    String channelId = playSound ? 'task_reminders_audio' : 'task_reminders_silent';
    String channelName = playSound ? 'Task Reminders (Audio)' : 'Task Reminders (Silent)';
    String channelDescription = playSound 
        ? 'Notifications with sound for task reminders'
        : 'Silent notifications for task reminders';
    
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      enableVibration: enableVibration,
      playSound: playSound,
      icon: '@mipmap/ic_launcher',
      color: Colors.blue,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  // Dispose resources
  void dispose() {
    cancelAllTasks();
    _observers.clear();
    log('TaskSubject disposed');
  }
} 