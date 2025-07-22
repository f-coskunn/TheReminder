import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Strategy interface for notification types
abstract class NotificationStrategy {
  Future<void> execute(Map<String, dynamic> data);
  String get name;
}

// Concrete strategy for vibration notifications
class VibrationStrategy implements NotificationStrategy {
  @override
  String get name => 'Vibration';

  @override
  Future<void> execute(Map<String, dynamic> data) async {
    try {
      // For vibration, we'll use a simple approach
      // In a real app, you would use a proper vibration plugin
      log('Vibration notification strategy executed for task: ${data['title']}');
      
      // Simulate vibration by logging
      log('VIBRATION: Device should vibrate for task: ${data['title']}');
      
      // Note: In a production app, you would use:
      // await Vibration.vibrate(pattern: [0, 500, 200, 500]);
      // But we're avoiding the problematic vibration plugin for now
    } catch (e) {
      log('Error executing vibration strategy: $e');
    }
  }
}

// Concrete strategy for visual notifications (flashing screen)
class VisualStrategy implements NotificationStrategy {
  @override
  String get name => 'Visual';

  @override
  Future<void> execute(Map<String, dynamic> data) async {
    try {
      // This strategy will be handled by the UI layer
      // The notification service will trigger visual effects
      log('Visual notification strategy executed for task: ${data['title']}');
      
      // Note: Visual notifications need to be handled in the UI layer
      // The actual visual notification will be triggered from the UI
      // when the notification observer receives the update
    } catch (e) {
      log('Error executing visual strategy: $e');
    }
  }
}

// Concrete strategy for audio notifications
class AudioStrategy implements NotificationStrategy {
  @override
  String get name => 'Audio';

  @override
  Future<void> execute(Map<String, dynamic> data) async {
    try {
      // For audio, we'll use the system notification sound
      // This is handled by the notification plugin
      log('Audio notification strategy executed for task: ${data['title']}');
    } catch (e) {
      log('Error executing audio strategy: $e');
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
      await _strategy!.execute(data);
    } else {
      log('No notification strategy set');
    }
  }

  NotificationStrategy? get currentStrategy => _strategy;
}

// Factory for creating notification strategies
class NotificationStrategyFactory {
  static NotificationStrategy createStrategy(String type) {
    switch (type.toLowerCase()) {
      case 'vibration':
        return VibrationStrategy();
      case 'visual':
        return VisualStrategy();
      case 'audio':
        return AudioStrategy();
      default:
        return AudioStrategy(); // Default to audio
    }
  }

  static List<String> get availableStrategies => ['Vibration', 'Visual', 'Audio'];
} 