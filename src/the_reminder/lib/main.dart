import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/db/settings_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/screens/createtaskscreen.dart';
import 'package:the_reminder/screens/homescreen.dart';
import 'package:the_reminder/screens/settingsscreen.dart';
import 'package:the_reminder/widgets/accessible_contrast_decorator.dart';
import 'package:the_reminder/widgets/accessible_font_decorator.dart';
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
  Map settings = {};
  @override
  void initState() {
    super.initState();
    _initApp(); // async veritabanı başlatma
  }

  Future<void> _initApp() async {
    db = DatabaseHelper.instance;
    tasks = await db.tasks;
    getSettings();
    log("settings:${settings.toString()}");
    setState(() {});
  }
  Future<void> getSettings() async {
    var s = await SettingsHelper.readData();
    setState(() {
      settings = s;
      log(settings.toString());
    });
  }

  void refreshState() async{
    await db.tasks.then((t){
      setState(() {
        tasks=t;
      });
    });
  }
  //TODO: change this to fontsize
  Widget _home(){
    Widget h = _homeScaffold();
    if(settings["fontSize"]!=null){
      return FontDecorator(_homeScaffold(),fontSize: settings["fontSize"],);
    }
    return _homeScaffold();
  }

  Widget _homeScaffold(){
    return Scaffold(
        appBar: const ReminderAppBar(),
        drawer: const ReminderAppDrawer(),
        floatingActionButton: TaskFloatingActionButton(callback: refreshState),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: HomeScreen() ,//HomeScreen(),
      );
  }

  //Theme decorator
  Widget _decoratedScaffold(){
    if(settings["isContrastEnabled"]!=null && settings["isContrastEnabled"])
    {return ContrastDecorator(_home());}
    return _home();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _decoratedScaffold()
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
                  MaterialPageRoute(builder: (context) => SettingsScreen())
                ).then((_){
                  (context.findAncestorStateOfType<_MainAppState>())?.getSettings();
                });
                
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
