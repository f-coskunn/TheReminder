//Oluşturulan taskların gösterildiği ana sayfa.
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/temp_singleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late List<Task> tasks;

  @override
  void initState() {
    super.initState();
    // Singleton'dan task listesini al
    tasks = TaskSingleton().tasks;
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Center(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              final task = tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.completed, 
                  onChanged: (e) {
                    log("${e}");
                    //TODO:tamamlanma değerini databasede de değiştir
                    setState(() {
                      task.setCompleted = e ?? false;
                    });
                  }
                ),
                title: Text(task.description),
                subtitle: Text(task.reminder),
                //Taskı sil
                trailing: IconButton(
                  color: Colors.red,
                  //TODO:Taskı databaseten de sil
                  onPressed:() =>setState(() {
                    TaskSingleton().deleteTask(index);
                  }), 
                  icon: Icon(Icons.delete)
                ),
              );
            },
          )
        );
  }
}