/*import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/task_model.dart';

// Simple timer-based notification service that should definitely work
class SimpleTimerNotificationService {
  static final SimpleTimerNotificationService _instance = SimpleTimerNotificationService._internal();
  factory SimpleTimerNotificationService() => _instance;
  SimpleTimerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Map<int, Timer> _timers = {};
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    
    // Request permissions
    await requestPermissions();
    
    _isInitialized = true;
    log('SimpleTimerNotificationService initialized');
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final hasPermission = (androidGranted ?? false) || (iosGranted ?? false);
    log('Notification permissions granted: $hasPermission');
    return hasPermission;
  }

  // Schedule a notification for a task using timer
  Future<void> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Parse the dueDateTime string to DateTime
      final dueDateTime = DateTime.parse(task.dueDateTime);
      
      // Check if the time is in the past
      if (dueDateTime.isBefore(DateTime.now())) {
        log('Task time is in the past, showing immediate notification');
        await showImmediateNotification(task.title, task.description);
        return;
      }
      
      final delay = dueDateTime.difference(DateTime.now());
      final taskId = task.taskID ?? 0;
      
      log('Scheduling notification for: ${task.title} at ${dueDateTime}');
      log('Current time: ${DateTime.now()}');
      log('Delay: ${delay.inMinutes} minutes and ${delay.inSeconds % 60} seconds');
      log('Task ID: $taskId');
      
      // Cancel any existing timer for this task
      _timers[taskId]?.cancel();
      
      // Create a timer for the notification
      _timers[taskId] = Timer(delay, () async {
        log('Timer fired for task: ${task.title}');
        await showImmediateNotification(task.title, task.description);
        _timers.remove(taskId);
      });
      
      log('Timer scheduled successfully for task: ${task.title}');
      log('Active timers: ${_timers.length}');
      
    } catch (e) {
      log('Error scheduling notification for task ${task.title}: $e');
      log('Error details: ${e.toString()}');
      // Fallback: show immediate notification if scheduling fails
      await showImmediateNotification(task.title, '${task.description} (Scheduled notification failed: ${e.toString()})');
    }
  }

  // Cancel notification for a specific task
  Future<void> cancelTaskNotification(int taskId) async {
    _timers[taskId]?.cancel();
    _timers.remove(taskId);
    await _notifications.cancel(taskId);
    log('Cancelled notification for task: $taskId');
  }

  // Show an immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Use a unique ID for immediate notifications
      title,
      body,
      details,
    );

    log('Immediate notification sent: $title');
  }

  // Get all pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _notifications.pendingNotificationRequests();
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    // Cancel all timers
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    
    await _notifications.cancelAll();
    log('Cancelled all notifications and timers');
  }

  // Get active timer count (for debugging)
  int getActiveTimerCount() {
    return _timers.length;
  }
} */