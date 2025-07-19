import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/services/notification_service.dart';
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
  var description="",date,title;
  DatabaseHelper db = DatabaseHelper.instance;

  Future _selectDateTime() async{
    DateTime?selectedDate = await _selectDate();
    log(selectedDate.toString());
    if (selectedDate==null) return;
    
    TimeOfDay? td = await _selectTime();
    log(td.toString());
    if (td==null) return;

    DateTime final_date =DateTime(
      selectedDate!.year,selectedDate!.month,selectedDate!.day,td.hour,td.minute
    );
    setState(() {
      date = final_date.toString();
    });
  }

  Future<DateTime?> _selectDate()=> showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

  Future<TimeOfDay?> _selectTime()=> showTimePicker(
      context: context, 
      initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Title inputu al
          Text("Title"),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value){
                setState(() {
                  title=value;
                });
              },
            ),
          ),
          //Descriptipn inputu al
          Text("Description"),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value){
                setState(() {
                  description=value;
                });
              },
            ),
          ),
          //add reminder

          //due date time inputu al
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Date input
              ElevatedButton(
                onPressed: (){
                  _selectDateTime();
                }, 
                child:date==null? Text("Pick a date"):Text(date)
              ),
            ],
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
                onPressed: () async {
                  //Listeye ekle
                  if(description != null && title != null && date != null){
                    log("Creating task: ${title}\n${description}\n${date}");
                    final task = Task(description: description, dueDateTime: date, title: title);
                    await db.addTask(task);
                    
                    log("Task created with ID: ${task.taskID}");
                    log("Scheduling notification for: ${task.dueDateTime}");
                    
                    // Schedule notification for the task
                    await NotificationService().scheduleTaskNotification(task);
                    
                    log("Task creation completed");
                    Navigator.pop(context);
                  } else {
                    log("Missing required fields: title=$title, description=$description, date=$date");
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