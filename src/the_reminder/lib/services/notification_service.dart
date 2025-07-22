import 'dart:developer';
import '../observer/task_subject.dart';
import '../observer/notification_observer.dart';
import '../model/task_model.dart';

// Service class that coordinates the Observer pattern for notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final TaskSubject _taskSubject = TaskSubject();
  final NotificationObserver _notificationObserver = NotificationObserver();
  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize observers
    await _notificationObserver.initialize();
    
    // Attach observers to subject
    _taskSubject.attach(_notificationObserver);
    
    _isInitialized = true;
    log('NotificationService initialized with ${_taskSubject.getActiveTimerCount()} active timers');
  }

  // Schedule a notification for a task
  Future<void> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }

    log('Scheduling notification for task: ${task.title}');
    _taskSubject.scheduleTask(task);
  }

  // Cancel notification for a specific task
  Future<void> cancelTaskNotification(int taskId) async {
    _taskSubject.cancelTask(taskId);
    await _notificationObserver.cancelNotification(taskId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    _taskSubject.cancelAllTasks();
    await _notificationObserver.cancelAllNotifications();
  }

  // Show an immediate notification (for testing)
  Future<void> showImmediateNotification(String title, String body) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _notificationObserver.showImmediateNotification(title, body);
  }

  // Get active timer count (for debugging)
  int getActiveTimerCount() {
    return _taskSubject.getActiveTimerCount();
  }

  // Handle overdue tasks manually (if needed)
  void handleOverdueTask(Task task) {
    _taskSubject.handleOverdueTask(task);
  }

  // Test a notification immediately (for testing)
  Future<void> testTaskNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }
    _taskSubject.triggerTaskNotification(task);
  }

  // Add a new observer (demonstrates extensibility)
  void addObserver(dynamic observer) {
    _taskSubject.attach(observer);
    log('New observer added. Total observers: ${_taskSubject.getActiveTimerCount()}');
  }

  // Remove an observer
  void removeObserver(dynamic observer) {
    _taskSubject.detach(observer);
    log('Observer removed. Total observers: ${_taskSubject.getActiveTimerCount()}');
  }

  // Dispose resources
  void dispose() {
    _taskSubject.dispose();
    log('NotificationService disposed');
  }

  // Get the task subject for direct access if needed
  TaskSubject get taskSubject => _taskSubject;
} 