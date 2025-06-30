import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/screens/createtaskscreen.dart';
import 'package:the_reminder/screens/homescreen.dart';
import 'package:the_reminder/temp_singleton.dart';

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

  @override
  void initState() {
    super.initState();
    _initApp(); // async veritabanı başlatma
  }

  Future<void> _initApp() async {
    await DatabaseHelper().database;
    tasks = TaskSingleton().tasks;
    setState(() {});
  }

  void refreshState() {
    log("Refreshing state after task creation");
    setState(() {
      tasks = TaskSingleton().tasks;
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
        body: const HomeScreen(),
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
                log("Tap on settings");
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
