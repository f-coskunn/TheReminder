//Oluşturulan taskların gösterildiği ana sayfa.
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/services/notification_service.dart';
//import 'package:the_reminder/temp_singleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<Task>> tasksFuture;
  DatabaseHelper db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    tasksFuture = db.tasks;
  }
  
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: db.tasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error loading tasks"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No tasks"));
        }

        final tasks = snapshot.data!;
        return Center(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  final task = tasks[index];
                  return ListTile(
                    leading: Checkbox(
                      value: task.isCompleted, 
                      onChanged: (e) {
                        log("${e}");
                        //TODO:tamamlanma değerini databasede de değiştir
                        setState(() {
                          task.setCompleted = e ?? false;
                        });
                      }
                    ),
                    title: Text(task.title ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        Text(task.dueDateTime),
                      ],
                    ),
                    //Taskı sil
                    trailing: IconButton(
                      color: Colors.red,
                      //TODO:Taskı databaseten de sil
                      onPressed:() async {
                        setState(() {
                          db.deleteTask(task.taskID??=0);
                        });
                        // Cancel notification for deleted task
                        await NotificationService().cancelTaskNotification(task.taskID ?? 0);
                      }, 
                      icon: Icon(Icons.delete)
                    ),
                  );
                },
              )
            );
      }
    );
  }
}