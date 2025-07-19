import 'dart:developer';
import 'observer.dart';

// Example of how easy it is to add new notification types with Observer pattern
class EmailObserver implements Observer {
  bool _isInitialized = false;

  // Initialize email service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Here you would initialize email service (SMTP, etc.)
    _isInitialized = true;
    log('EmailObserver initialized');
  }

  @override
  void update(String message, Map<String, dynamic> data) {
    log('EmailObserver received update: $message');
    
    if (!_isInitialized) {
      initialize().then((_) => _handleUpdate(message, data));
    } else {
      _handleUpdate(message, data);
    }
  }

  void _handleUpdate(String message, Map<String, dynamic> data) {
    switch (message) {
      case 'TASK_DUE':
        _sendTaskDueEmail(data);
        break;
      case 'TASK_OVERDUE':
        _sendTaskOverdueEmail(data);
        break;
      case 'TASK_ERROR':
        _sendTaskErrorEmail(data);
        break;
      default:
        log('Unknown message type: $message');
    }
  }

  void _sendTaskDueEmail(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Due';
    final description = data['description'] ?? '';
    
    // Here you would send actual email
    log('Sending email: Task Due - $title');
    log('Email content: $description');
  }

  void _sendTaskOverdueEmail(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Overdue';
    final description = data['description'] ?? '';
    
    // Here you would send actual email
    log('Sending email: Task Overdue - $title');
    log('Email content: $description');
  }

  void _sendTaskErrorEmail(Map<String, dynamic> data) {
    final title = data['title'] ?? 'Task Error';
    final description = data['description'] ?? '';
    
    // Here you would send actual email
    log('Sending email: Task Error - $title');
    log('Email content: $description');
  }
} 