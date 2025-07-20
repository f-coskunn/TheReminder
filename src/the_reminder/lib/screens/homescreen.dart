//Oluşturulan taskların gösterildiği ana sayfa.
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/widgets/accessible_font_decorator.dart';
import 'package:the_reminder/widgets/high_priority_decorator.dart';
import 'package:the_reminder/widgets/low_priority_decorator.dart';
//import 'package:the_reminder/temp_singleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //Check for accessibility settings and decorate accordingly

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
                  Widget tile = ListTile(
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
                        onPressed:() =>setState(() {
                          db.deleteTask(task.taskID??=0);
                        }), 
                        icon: Icon(Icons.delete)
                      ),
                    );
                  Widget _getTile(){
                    log(task.priority.toString());
                    switch (task.priority) {
                      case Priority.High:
                        return HighPriorityDecorator(tile);
                      case Priority.Low:
                        return LowPriorityDecorator(tile);
                      default:
                        return tile;
                    }
                  }
                  return _getTile();
                },
              )
            );
      }
    );
  }
}