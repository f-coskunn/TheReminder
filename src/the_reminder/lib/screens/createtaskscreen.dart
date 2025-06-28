import 'package:flutter/material.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/temp_singleton.dart';

class CreatetaskScreen extends StatelessWidget {
  const CreatetaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CreateTask(),
    );
  }
}

class CreateTask extends StatefulWidget {
  const CreateTask({
    super.key,
  });

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  var description,date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            onChanged: (value){
              setState(() {
                description=value;
              });
            },
          ),
          TextField(
            onChanged: (value){
              setState(() {
                date=value;
              });
            },

          ),
          //Geri ve task ekle tuşları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: ()=>Navigator.pop(context), 
                child: Text("Back")
              ),
              ElevatedButton(
                onPressed: (){
                  //Listeye ekle
                  if(description!=null && date!=null){
                    TaskSingleton().addTask(Task(description:description,reminder:date));
                    Navigator.pop(context);
                  }
                  
                }, 
                child: Text("Add Task")
              ),
              
            ],
          )
        ],
      ),
      );
  }
}