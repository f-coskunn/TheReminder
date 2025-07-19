/*import 'dart:developer';
import 'task_subject.dart';
import 'notification_observer.dart';
import '../model/task_model.dart';

// Service class that manages the Observer pattern for notifications
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

    await _notificationObserver.initialize();
    _taskSubject.attach(_notificationObserver);
    
    // Request permissions
    final hasPermission = await _notificationObserver.requestPermissions();
    if (!hasPermission) {
      log('Notification permissions not granted');
    }

    _isInitialized = true;
    log('NotificationService initialized');
  }

  // Schedule a notification for a task
  Future<void> scheduleTaskNotification(Task task) async {
    if (!_isInitialized) {
      await initialize();
    }
    await _scheduleTask(task);
  }

  Future<void> _scheduleTask(Task task) async {
    try {
      // Parse the dueDateTime string to DateTime
      final dueDateTime = DateTime.parse(task.dueDateTime);
      
      // Create task data for notification
      final taskData = {
        'taskID': task.taskID,
        'title': task.title,
        'description': task.description,
        'dueDateTime': task.dueDateTime,
        'priority': task.priority.name,
      };

      // Schedule the notification
      await _taskSubject.scheduleNotification(dueDateTime, taskData);
      
      log('Scheduled notification for task: ${task.title} at ${dueDateTime}');
    } catch (e) {
      log('Error scheduling notification for task ${task.title}: $e');
    }
  }

  // Cancel notification for a specific task
  Future<void> cancelTaskNotification(int taskId) async {
    await _taskSubject.cancelNotification(taskId);
    log('Cancelled notifications for task: $taskId');
  }

  // Update notification for a task (e.g., when task is modified)
  void updateTaskNotification(Task task) {
    cancelTaskNotification(task.taskID ?? 0);
    scheduleTaskNotification(task);
  }

  // Dispose resources
  void dispose() {
    _taskSubject.dispose();
    log('NotificationService disposed');
  }
  // Rescheduling Tasks (When app restarted, it reschedules the tasks depending on their due dates)
  Future<void> rescheduleAllTasks(List<Task> allTasks) async {
      for(final task in allTasks) {
        final dueDate = DateTime.parse(task.dueDateTime);
        if(dueDate.isAfter(DateTime.now()) {
            await scheduleTaskNotification(task);
        }  
      }
  }
  // Get the task subject for direct access if needed
  TaskSubject get taskSubject => _taskSubject;
} 
*/