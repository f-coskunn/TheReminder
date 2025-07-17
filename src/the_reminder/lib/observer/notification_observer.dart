import 'dart:developer';
import 'observer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

// Concrete implementation of Observer for phone notifications
class NotificationObserver implements Observer {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
    log('Notification system initialized');
  }

  @override
  void update(String message, Map<String, dynamic> data) {
    if (!_isInitialized) {
      initialize().then((_) => _showNotification(message, data));
    } else {
      _showNotification(message, data);
    }
  }

  // Schedule a notification for a specific time
  Future<void> scheduleNotification(DateTime scheduledTime, Map<String, dynamic> data) async {
    if (!_isInitialized) {
      await initialize();
    }

    final taskTitle = data['title'] ?? 'Task Reminder';
    final taskDescription = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
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

    await _notifications.zonedSchedule(
      taskId,
      taskTitle,
      taskDescription,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    log('Scheduled notification for task $taskId at $scheduledTime');
  }

  // Cancel a scheduled notification
  Future<void> cancelNotification(int taskId) async {
    await _notifications.cancel(taskId);
    log('Cancelled notification for task $taskId');
  }

  void _showNotification(String message, Map<String, dynamic> data) {
    final taskTitle = data['title'] ?? 'Task Reminder';
    final taskDescription = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;

    const androidDetails = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
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

    _notifications.show(
      taskId,
      taskTitle,
      taskDescription,
      details,
    );

    log('Notification sent: $message for task $taskId');
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) {
      await initialize();
    }

    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return (androidGranted ?? false) || (iosGranted ?? false);
  }
} 