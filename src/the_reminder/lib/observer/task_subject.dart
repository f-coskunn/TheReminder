import 'dart:async';
import 'observer.dart';
import 'subject.dart';
import 'notification_observer.dart';

// Concrete implementation of Subject for tasks
class TaskSubject implements Subject {
  final List<Observer> _observers = [];
  Timer? _timer;

  @override
  void attach(Observer observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  @override
  void detach(Observer observer) {
    _observers.remove(observer);
  }

  @override
  void notify(String message, Map<String, dynamic> data) {
    for (Observer observer in _observers) {
      observer.update(message, data);
    }
  }

  // Schedule a notification for a specific time using proper scheduling
  Future<void> scheduleNotification(DateTime dueTime, Map<String, dynamic> taskData) async {
    final now = DateTime.now();
    final delay = dueTime.difference(now);
    
    if (delay.isNegative) {
      // Task is already overdue, notify immediately
      notify('TASK_OVERDUE', taskData);
    } else {
      // Use proper notification scheduling instead of Timer
      for (Observer observer in _observers) {
        if (observer is NotificationObserver) {
          await observer.scheduleNotification(dueTime, taskData);
        }
      }
    }
  }

  // Cancel scheduled notifications
  Future<void> cancelNotification(int taskId) async {
    for (Observer observer in _observers) {
      if (observer is NotificationObserver) {
        await observer.cancelNotification(taskId);
      }
    }
  }

  // Cancel all scheduled notifications
  void cancelNotifications() {
    _timer?.cancel();
  }

  // Dispose resources
  void dispose() {
    cancelNotifications();
    _observers.clear();
  }
} 