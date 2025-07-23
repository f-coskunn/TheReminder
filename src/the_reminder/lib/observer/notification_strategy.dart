import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Strategy interface for notification types
abstract class NotificationStrategy {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  Future<void> execute(Map<String, dynamic> data,Color color);
  String get name;
}

// Concrete strategy for vibration notifications
class VibrationStrategy implements NotificationStrategy {
  @override
  String get name => 'Vibration';

  @override
  Future<void> execute(Map<String, dynamic> data,Color color) async {
    final title = data['title'] ?? 'Task Due';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];
    try {
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

    _notifications.show(taskId, title, description, details);
    log('Custom notification sent: $title with types: ${notificationTypes.join(', ')}');
    log('Sound enabled: ${notificationTypes.contains('Audio')}');
    log('Vibration enabled: ${notificationTypes.contains('Vibration')}');
      log('Visual notification strategy executed for task: ${data['title']}');
      
      // Note: Visual notifications need to be handled in the UI layer
      // The actual visual notification will be triggered from the UI
      // when the notification observer receives the update
    } catch (e) {
      log('Error executing visual strategy: $e');
    }
  }
  
  @override
  FlutterLocalNotificationsPlugin get _notifications => FlutterLocalNotificationsPlugin();
}

// Concrete strategy for visual notifications (flashing screen)
class VisualStrategy implements NotificationStrategy {
  @override
  String get name => 'Visual';

  @override
  Future<void> execute(Map<String, dynamic> data,Color color) async {
    final title = data['title'] ?? 'Task Due';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];
    try {
      // Create different notification details based on selected types
    NotificationDetails details;
    final androidDetails = AndroidNotificationDetails(
        'task_reminders_silent',
        'Task Reminders (Silent)',
        channelDescription: 'Silent notifications for task reminders',
        importance: Importance.high,
        enableVibration: false,
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

    _notifications.show(taskId, title, description, details);
    log('Custom notification sent: $title with types: ${notificationTypes.join(', ')}');
    log('Sound enabled: ${notificationTypes.contains('Audio')}');
    log('Vibration enabled: ${notificationTypes.contains('Vibration')}');
      log('Visual notification strategy executed for task: ${data['title']}');
      
      // Note: Visual notifications need to be handled in the UI layer
      // The actual visual notification will be triggered from the UI
      // when the notification observer receives the update
    } catch (e) {
      log('Error executing visual strategy: $e');
    }
  }
  
  @override
  FlutterLocalNotificationsPlugin get _notifications => FlutterLocalNotificationsPlugin();
}

// Concrete strategy for audio notifications
class AudioStrategy implements NotificationStrategy {
  @override
  FlutterLocalNotificationsPlugin get _notifications => FlutterLocalNotificationsPlugin();
  @override
  String get name => 'Audio';

  @override
  Future<void> execute(Map<String, dynamic> data,Color color) async {
    log("AUDİO STRATEGY EXECUTED///////////////////////////////////////////////////////////////");
    final title = data['title'] ?? 'Task Due';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];
    try {
      // Create different notification details based on selected types
    NotificationDetails details;
    log("Contains vibration? ${notificationTypes.contains('Vibration')}");
    final androidDetails = AndroidNotificationDetails(
        'task_reminders_audio',
        'Task Reminders (Audio)',
        channelDescription: 'Notifications with sound for task reminders',
        importance: Importance.high,
        enableVibration: false,
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

    _notifications.show(taskId, title, description, details);
    log('Custom notification sent: $title with types: ${notificationTypes.join(', ')}');
    log('Sound enabled: ${notificationTypes.contains('Audio')}');
    log('Vibration enabled: ${notificationTypes.contains('Vibration')}');
      log('Visual notification strategy executed for task: ${data['title']}');
      
      // Note: Visual notifications need to be handled in the UI layer
      // The actual visual notification will be triggered from the UI
      // when the notification observer receives the update
    } catch (e) {
      log('Error executing visual strategy: $e');
    }
  }
}

// Concrete strategy for audio and vibartion notifications
class AudioVibrationStrategy implements NotificationStrategy {
  @override
  FlutterLocalNotificationsPlugin get _notifications => FlutterLocalNotificationsPlugin();
  @override
  String get name => 'Audio';

  @override
  Future<void> execute(Map<String, dynamic> data,Color color) async {
    log("VİBRATİON AND AUDİO FEEDBACk //////////////////////////////////////");
    final title = data['title'] ?? 'Task Due';
    final description = data['description'] ?? '';
    final taskId = data['taskID'] ?? 0;
    final notificationTypes = (data['notificationTypes'] as List<dynamic>?)?.cast<String>() ?? ['Audio'];
    try {
      // Create different notification details based on selected types
    NotificationDetails details;
    log("Contains vibration? ${notificationTypes.contains('Vibration')}");
    final androidDetails = AndroidNotificationDetails(
        'task_reminders_audio_vibration',
        'Task Reminders (Audio Vibration)',
        channelDescription: 'Notifications with sound and vibration for task reminders',
        importance: Importance.high,
        enableVibration: true,
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

    _notifications.show(taskId, title, description, details);
    log('Custom notification sent: $title with types: ${notificationTypes.join(', ')}');
    log('Sound enabled: ${notificationTypes.contains('Audio')}');
    log('Vibration enabled: ${notificationTypes.contains('Vibration')}');
      log('Visual notification strategy executed for task: ${data['title']}');
      
      // Note: Visual notifications need to be handled in the UI layer
      // The actual visual notification will be triggered from the UI
      // when the notification observer receives the update
    } catch (e) {
      log('Error executing visual strategy: $e');
    }
  }
}

// Strategy context that manages which strategy to use
class NotificationStrategyContext {
  NotificationStrategy? _strategy;

  void setStrategy(NotificationStrategy strategy) {
    _strategy = strategy;
  }

  Future<void> executeStrategy(Map<String, dynamic> data) async {
    if (_strategy != null) {
      await _strategy!.execute(data,Colors.blue);
    } else {
      log('No notification strategy set');
    }
  }

  NotificationStrategy? get currentStrategy => _strategy;
}

// Factory for creating notification strategies
class NotificationStrategyFactory {
  static NotificationStrategy createStrategy(List<String> types) {
    log("Types in the factory: ${types.toString()}");
    if(types.length==3){
      return AudioVibrationStrategy();
    }else{
      switch (types[1].toLowerCase()) {
      case 'vibration':
      log("Vibration strategy");
        return VibrationStrategy();
      case 'visual':
      log("Visual strategy");
        return VisualStrategy();
      case 'audio':
      log("Audio strategy");
        return AudioStrategy();
      default:
        return AudioVibrationStrategy(); // Default to audio
    }
    }
    
  }

  static List<String> get availableStrategies => ['Vibration', 'Visual', 'Audio'];
} 