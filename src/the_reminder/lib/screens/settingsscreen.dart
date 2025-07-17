import 'package:flutter/material.dart';
import 'package:the_reminder/services/simple_timer_notification_service.dart';
import 'package:the_reminder/model/task_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
                          ElevatedButton(
                onPressed: () async {
                  await SimpleTimerNotificationService().showImmediateNotification(
                    'Test Notification',
                    'This is a test notification to verify the system is working.',
                  );
                },
                child: const Text('Test Notification (Immediate)'),
              ),
                        const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                // Create a test task for 10 seconds from now
                final testTask = Task(
                  title: 'Scheduled Test Task',
                  description: 'This is a test scheduled notification',
                  dueDateTime: DateTime.now().add(const Duration(seconds: 10)).toString(),
                );
                
                await SimpleTimerNotificationService().scheduleTaskNotification(testTask);
                print('Scheduled test notification for 10 seconds from now');
              },
              child: const Text('Test Scheduled Notification (10 seconds)'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Debug Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final pending = await SimpleTimerNotificationService().getPendingNotifications();
                final activeTimers = SimpleTimerNotificationService().getActiveTimerCount();
                print('=== PENDING NOTIFICATIONS ===');
                print('Total pending: ${pending.length}');
                print('Active timers: $activeTimers');
                for (var notification in pending) {
                  print('ID: ${notification.id}, Title: ${notification.title}');
                }
                print('=============================');
              },
              child: const Text('Check Pending Notifications'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await SimpleTimerNotificationService().cancelAllNotifications();
                print('All notifications cancelled');
              },
              child: const Text('Cancel All Notifications'),
            ),
          ],
        ),
      ),
    );
  }
}