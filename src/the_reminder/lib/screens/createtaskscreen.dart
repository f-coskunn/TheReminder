import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/db/settings_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/widgets/accessible_font_decorator.dart';
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
  DatabaseHelper db = DatabaseHelper.instance;

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
                  onPressed: (){
                    //Listeye ekle
                    if(description!=title){
                      log("${title}\n${description}\n${date}");
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