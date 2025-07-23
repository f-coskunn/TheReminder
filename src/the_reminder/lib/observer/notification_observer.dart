import 'dart:developer';
import 'observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_strategy.dart';
import '../model/task_model.dart';

// Concrete implementation of Observer for phone notifications
class NotificationObserver implements Observer {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final NotificationStrategyContext _strategyContext = NotificationStrategyContext();
  bool _isInitialized = false;

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

  @override
  void update(String message, Map<String, dynamic> data) {
    log('NotificationObserver received update: $message');
    
    if (!_isInitialized) {
      initialize().then((_) => _handleUpdate(message, data));
    } else {
      _handleUpdate(message, data);
    }
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
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];
    log("Notification types:${notificationTypes.toString()}");
    _executeNotificationStrategies(data, notificationTypes);
    _showCustomNotification(taskId, title, description, Colors.blue, notificationTypes);
  }

  void _showTaskOverdueNotification(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Overdue';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];

    _executeNotificationStrategies(data, notificationTypes);
    _showCustomNotification(taskId, '$title (OVERDUE)', description, Colors.red, notificationTypes);
  }

  void _showTaskErrorNotification(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Error';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];

    _executeNotificationStrategies(data, notificationTypes);
    _showCustomNotification(taskId, '$title (ERROR)', description, Colors.orange, notificationTypes);
  }

  void _executeNotificationStrategies(Map<String, dynamic> data, List<String> notificationTypes) {
    // Execute all selected notification strategies
    for (final notificationType in notificationTypes) {
      final strategy = NotificationStrategyFactory.createStrategy(notificationType);
      _strategyContext.setStrategy(strategy);
      _strategyContext.executeStrategy(data);
    }
  }

  void _showCustomNotification(int id, String title, String body, Color color, List<String> notificationTypes) {
    // Create different notification details based on selected types
    NotificationDetails details;
    log("Contains vibration? ${notificationTypes.contains('Vibration')}");
    if (notificationTypes.contains('Audio')) {
      // Audio notification - with sound
      final androidDetails = AndroidNotificationDetails(
        'task_reminders_audio',
        'Task Reminders (Audio)',
        channelDescription: 'Notifications with sound for task reminders',
        importance: Importance.high,
        enableVibration: notificationTypes.contains('Vibration'),
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: color,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
    } else {
      // Silent notification - no sound
      final androidDetails = AndroidNotificationDetails(
        'task_reminders_silent',
        'Task Reminders (Silent)',
        channelDescription: 'Silent notifications for task reminders',
        importance: Importance.high,
        enableVibration: notificationTypes.contains('Vibration'),
        playSound: false,
        icon: '@mipmap/ic_launcher',
        color: color,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
    }

    _notifications.show(id, title, body, details);
    log('Custom notification sent: $title with types: ${notificationTypes.join(', ')}');
    log('Sound enabled: ${notificationTypes.contains('Audio')}');
    log('Vibration enabled: ${notificationTypes.contains('Vibration')}');
  }

  // Handle background notification with proper notification types
  void _handleBackgroundNotification(int id, String title, String body, Color color, List<String> notificationTypes) {
    // For background notifications, we need to show the notification immediately
    // but we can still respect the notification types for the strategy execution
    _showCustomNotification(id, title, body, color, notificationTypes);
  }

  // Show an immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body, {List<String> notificationTypes = const ['Audio']}) async {
    if (!_isInitialized) {
      await initialize();
    }

    _showCustomNotification(999, title, body, Colors.blue, notificationTypes);
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

  // Test different notification strategies
  Future<void> testNotificationStrategy(String strategyType, Map<String, dynamic> data) async {
    final strategy = NotificationStrategyFactory.createStrategy(strategyType);
    _strategyContext.setStrategy(strategy);
    await _strategyContext.executeStrategy(data);
  }

  // Test notification with specific types
  Future<void> testNotificationWithTypes(List<String> notificationTypes, String title, String body) async {
    await showImmediateNotification(title, body, notificationTypes: notificationTypes);
  }
} 