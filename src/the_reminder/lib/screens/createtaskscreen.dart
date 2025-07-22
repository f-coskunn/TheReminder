import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/db/settings_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/services/notification_service.dart';
import 'package:the_reminder/widgets/accessible_font_decorator.dart';
import 'package:the_reminder/widgets/notification_type_selector.dart';
//import 'package:the_reminder/temp_singleton.dart';

class CreatetaskScreen extends StatefulWidget {
  const CreatetaskScreen({super.key});

  @override
  State<CreatetaskScreen> createState() => _CreatetaskScreenState();
}

class _CreatetaskScreenState extends State<CreatetaskScreen> {
  late Map settings={};
  @override
  void initState() {
    super.initState();
    _getSettings();
  }
  Future<void> _getSettings() async {
    var s = await SettingsHelper.readData();
    setState(() {
      settings = s;
      log(settings.toString());
    });
  }

  Widget _getScaffold(){
    if(settings["fontSize"]!=null){
      return FontDecorator(
        Scaffold(
          body: CreateTask(),
        ),
        fontSize: settings["fontSize"],
      );
    }
    return Scaffold(
        body: CreateTask(),
      );
  }
 
  @override
  Widget build(BuildContext context) {
    return _getScaffold();
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
  List<NotificationType> selectedNotificationTypes = [NotificationType.Visual];
  DatabaseHelper db = DatabaseHelper.instance;
  Priority? _priority = Priority.Medium;

  //Check for accessibility settings and decorate accordingly

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
      child: ListView(
        shrinkWrap: true,
        children: [
          //Title inputu al
          Center(
            child: Text(
              "Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
            child: TextField(
              onChanged: (value){
                setState(() {
                  title=value;
                });
              },
            ),
          ),
          //Descriptipn inputu al
          Center(
            child: Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
            child: TextField(
              onChanged: (value){
                setState(() {
                  description=value;
                });
              },
            ),
          ),

          //add priority
          Center(
            child: Text(
              "Priority",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('Low'),
            leading: Radio<Priority>(
              value: Priority.Low, 
              groupValue: _priority, 
              onChanged: (e){
                setState(() {
                  _priority = e;
                  log("Priority changed to $e");
                });
              }
            ),
          ),
          ListTile(
            title: const Text('Medium'),
            leading: Radio<Priority>(
              value: Priority.Medium, 
              groupValue: _priority, 
              onChanged: (e){
                setState(() {
                  _priority = e;
                  log("Priority changed to $e");
                });
              }
            ),
          ),
          ListTile(
            title: const Text('High'),
            leading: Radio<Priority>(
              value: Priority.High, 
              groupValue: _priority, 
              onChanged: (e){
                setState(() {
                  _priority = e;
                  log("Priority changed to $e");
                });
              }
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
          
          // Notification type selection
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: NotificationTypeSelector(
              selectedTypes: selectedNotificationTypes,
              onChanged: (List<NotificationType> types) {
                setState(() {
                  selectedNotificationTypes = types;
                });
              },
            ),
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
                    try {
                      log("Creating task: ${title}\n${description}\n${date}");
                      final task = Task(
                        description: description, 
                        dueDateTime: date, 
                        title: title,
                        notificationTypes: selectedNotificationTypes,
                      );
                      int id = await db.addTask(task);
                      task.taskID=id;
                      
                      log("Task created with ID: ${task.taskID}");
                      log("Scheduling notification for: ${task.dueDateTime}");
                      
                      // Schedule notification for the task
                      await NotificationService().scheduleTaskNotification(task);
                      
                      log("Task creation completed");
                      Navigator.pop(context);
                    } catch (e) {
                      log("Error creating task: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating task: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    log("Missing required fields: title=$title, description=$description, date=$date");
                    // Show warning message to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all the blanks'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
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