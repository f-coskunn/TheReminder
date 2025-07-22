import 'dart:developer';
import 'observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../strategy/reminder_strategy.dart';
//import 'notification_observer.dart';
import '../strategy/audio_reminder.dart';
import '../strategy/vibration_reminder.dart';
import '../strategy/visual_reminder.dart';

// Concrete implementation of Observer for phone notifications
class NotificationObserver implements Observer {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final ReminderStrategy strategy;
  bool _isInitialized = false;

  NotificationObserver({required this.strategy});

  // Initialize notifications
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
    log('NotificationObserver initialized');
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

  /*@override
  void update(String message, Map<String, dynamic> data) {
    // You can use data if needed (e.g. show task name in visual reminder)

  } */

  
  @override
  void update(String message, Map<String, dynamic> data) {
    log('NotificationObserver received update: $message');
    
    if (!_isInitialized) {
      initialize().then((_) => _handleUpdate(message, data));
    } else {
      _handleUpdate(message, data);
    }

    strategy.remind();
  }

  void _handleUpdate(String message, Map<String, dynamic> data) {
    switch (message) {
      case 'TASK_DUE':
        _showTaskDueNotification(data);
        break;
      case 'TASK_OVERDUE':
        _showTaskOverdueNotification(data);
        break;
      case 'TASK_ERROR':
        _showTaskErrorNotification(data);
        break;
      default:
        log('Unknown message type: $message');
    }
  }

  void _showTaskDueNotification(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Due';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;

    _showNotification(
      taskId,
      title,
      description,
      Colors.blue,
    );
  }

  void _showTaskOverdueNotification(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Overdue';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;

    _showNotification(
      taskId,
      '$title (OVERDUE)',
      description,
      Colors.red,
    );
  }

  void _showTaskErrorNotification(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Error';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;

    _showNotification(
      taskId,
      '$title (ERROR)',
      description,
      Colors.orange,
    );
  }

  void _showNotification(int id, String title, String body, Color color) {
    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Colors.blue,
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

    _notifications.show(id, title, body, details);
    log('Notification sent: $title');
  }

  // Show an immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }

    _showNotification(999, title, body, Colors.blue);
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int taskId) async {
    await _notifications.cancel(taskId);
    log('Cancelled notification for task: $taskId');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    log('Cancelled all notifications');
  }
} 