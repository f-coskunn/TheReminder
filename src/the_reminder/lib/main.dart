import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/screens/createtaskscreen.dart';
import 'package:the_reminder/screens/homescreen.dart';
import 'package:the_reminder/screens/settingsscreen.dart';
import 'package:the_reminder/services/simple_timer_notification_service.dart';
//import 'package:the_reminder/temp_singleton.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late List<Task> tasks;
  late DatabaseHelper db;

  @override
  void initState() {
    super.initState();
    _initApp(); // async veritabanı başlatma
  }

  Future<void> _initApp() async {
    db = DatabaseHelper.instance;
    tasks = await db.tasks;
    
    // Initialize notification service
    await SimpleTimerNotificationService().initialize();
    
    // Reschedule notifications for existing tasks
    await _rescheduleNotifications();
    
    setState(() {});
  }

  Future<void> _rescheduleNotifications() async {
    try {
      final allTasks = await db.tasks;
      for (final task in allTasks) {
        if (!task.isCompleted) {
          await SimpleTimerNotificationService().scheduleTaskNotification(task);
        }
      }
      log('Rescheduled notifications for ${allTasks.length} tasks');
    } catch (e) {
      log('Error rescheduling notifications: $e');
    }
  }

  void refreshState() async{
    await db.tasks.then((t){
      setState(() {
        tasks=t;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: const ReminderAppBar(),
        drawer: const ReminderAppDrawer(),
        floatingActionButton: TaskFloatingActionButton(callback: refreshState),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: HomeScreen(),
      ),
    );
  }
}

class ReminderAppDrawer extends StatelessWidget {
  const ReminderAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              title: const Text("Settings"),
              trailing: const Icon(Icons.settings),
            )
          ],
        ),
      ),
    );
  }
}

class ReminderAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReminderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("TheReminder"),
      forceMaterialTransparency: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class TaskFloatingActionButton extends StatefulWidget {
  final VoidCallback callback;
  const TaskFloatingActionButton({super.key, required this.callback});

  @override
  State<TaskFloatingActionButton> createState() =>
      _TaskFloatingActionButtonState();
}

class _TaskFloatingActionButtonState extends State<TaskFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatetaskScreen()),
        ).then((_) => widget.callback());
      },
      shape: const CircleBorder(),
      child: const Icon(Icons.edit_outlined),
    );
  }
}
