import 'package:flutter/material.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/model/task_model.dart';
//import 'package:the_reminder/temp_singleton.dart';

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
  var description,date,title;
  DatabaseHelper db = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Title inputu al
          TextField(
            onChanged: (value){
              setState(() {
                title=value;
              });
            },
          ),
          //Descriptipn inputu al
          TextField(
            onChanged: (value){
              setState(() {
                description=value;
              });
            },
          ),
          //dudatetime inputu al
          //TODO: bu değiştirilcek
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
                    db.addTask(Task(description:description,dueDateTime:date, title:title));
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