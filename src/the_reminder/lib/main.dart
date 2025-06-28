import 'dart:developer';

import 'package:flutter/material.dart';
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
  //TODO: Burada singletonın initilize olması gerekiyor
  late List<Task> tasks;
  @override
  void initState() {
    super.initState();
    tasks = TaskSingleton().tasks;
  }

  refreshState(){
    log("here");
    setState(() {
      tasks = TaskSingleton().tasks;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        //En üstte menü tuşu ve uygulama adı bulunan yer
        appBar: const ReminderAppBar(),

        //Sol taraftan açılan menü
        drawer: ReminderAppDrawer(),

        //Task ekleme tuşu
        floatingActionButton: TaskFloatingActionButton(callback:refreshState),
        //Task ekleme tuşunun konumu
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        //Ana sayfa
        body: HomeScreen()
      ),
    );
  }
}

class ReminderAppDrawer extends StatelessWidget {
  const ReminderAppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: ListView(
          children: [
            ListTile(
              //Basıldığında Ayarlar sayfasına yönlendir
              onTap: () {
                log("Tap on settings");
              },
              title: Text("Settings"),
              trailing: Icon(Icons.settings),
            )
          ],
        ),
      ),
    );
  }
}


//Uygulamanın en üstünde uygulamanın adını ve mennü tuşunu gösteren kısım
class ReminderAppBar extends StatelessWidget implements PreferredSizeWidget{
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

//Yeni task eklemek için sayfanın altında basılması gereken tuş
//Tuş kullanıcıyı yeni task oluşturma ekranına yönlendirir
class TaskFloatingActionButton extends StatefulWidget {
  final VoidCallback callback;
  const TaskFloatingActionButton({super.key, required this.callback});

  @override
  State<TaskFloatingActionButton> createState() => _TaskFloatingActionButtonState();
}

class _TaskFloatingActionButtonState extends State<TaskFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.large(
      //Tuşa basılınca task yaratma sayfasına git
      onPressed: (){
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => const CreatetaskScreen()
          )
        ).then((e)=>widget.callback());
      },
      shape: CircleBorder(),
      child: const Icon(Icons.edit_outlined),
    );
  }
}
