import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_reminder/db/database_helper.dart';
import 'package:the_reminder/db/settings_helper.dart';
import 'package:the_reminder/model/task_model.dart';
import 'package:the_reminder/services/notification_service.dart';
import 'package:the_reminder/widgets/accessible_font_decorator.dart';
import 'package:the_reminder/widgets/notification_type_selector.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  
  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late Map settings = {};
  
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

  Widget _getScaffold() {
    if (settings["fontSize"] != null) {
      return FontDecorator(
        Scaffold(
          body: EditTask(task: widget.task),
        ),
        fontSize: settings["fontSize"],
      );
    }
    return Scaffold(
      body: EditTask(task: widget.task),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return _getScaffold();
  }
}

class EditTask extends StatefulWidget {
  final Task task;
  
  const EditTask({
    super.key,
    required this.task,
  });

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  late String description;
  late String date;
  late String title;
  late List<NotificationType> selectedNotificationTypes;
  late Priority priority;
  DatabaseHelper db = DatabaseHelper.instance;
  
  // Add persistent controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Initialize with existing task data
    description = widget.task.description ?? "";
    date = widget.task.dueDateTime ?? "";
    title = widget.task.title ?? "";
    selectedNotificationTypes = List.from(widget.task.notificationTypes);
    priority = widget.task.priority;
    
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: title);
    _descriptionController = TextEditingController(text: description);
    
    log("Edit task with values:$description $date $title $priority");
  }
  
  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future _selectDateTime() async {
    DateTime? selectedDate = await _selectDate();
    log(selectedDate.toString());
    if (selectedDate == null) return;
    
    TimeOfDay? td = await _selectTime();
    log(td.toString());
    if (td == null) return;

    DateTime final_date = DateTime(
      selectedDate!.year, selectedDate!.month, selectedDate!.day, td.hour, td.minute
    );
    setState(() {
      date = final_date.toString();
    });
  }

  Future<DateTime?> _selectDate() => showDatePicker(
    context: context,
    initialDate: DateTime.parse(widget.task.dueDateTime ?? DateTime.now().toString()),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  Future<TimeOfDay?> _selectTime() => showTimePicker(
    context: context, 
    initialTime: TimeOfDay(
      hour: DateTime.parse(widget.task.dueDateTime ?? DateTime.now().toString()).hour, 
      minute: DateTime.parse(widget.task.dueDateTime ?? DateTime.now().toString()).minute
    )
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          // Title input
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
              controller: _titleController,
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
          ),
          // Description input
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
              controller: _descriptionController,
              onChanged: (value) {
                setState(() {
                  description = value;
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
              groupValue: priority, 
              onChanged: (e){
                setState(() {
                  priority = e ?? Priority.Low;
                  log("Priority changed to $e");
                });
              }
            ),
          ),
          ListTile(
            title: const Text('Medium'),
            leading: Radio<Priority>(
              value: Priority.Medium, 
              groupValue: priority, 
              onChanged: (e){
                setState(() {
                  priority = e ?? Priority.Medium;
                  log("Priority changed to $e");
                });
              }
            ),
          ),
          ListTile(
            title: const Text('High'),
            leading: Radio<Priority>(
              value: Priority.High, 
              groupValue: priority, 
              onChanged: (e){
                setState(() {
                  priority = e ?? Priority.High;
                  log("Priority changed to $e");
                });
              }
            ),
          ),
          // Due date time input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _selectDateTime();
                }, 
                child: date == null ? Text("Pick a date") : Text(date)
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
                  log('Selected notification types are:${types.toString()}');
                });
              },
            ),
          ),
          
          // Back and Update buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context), 
                child: Text("Cancel")
              ),
              ElevatedButton(
                onPressed: () async {
                  // Update task
                  if (description.isNotEmpty && title.isNotEmpty && date.isNotEmpty) {
                    try {
                      log("Updating task: ${title}\n${description}\n${date}");
                      
                      // Cancel existing notification
                      await NotificationService().cancelTaskNotification(widget.task.taskID ?? 0);
                      
                      // Update task with new data
                      final updatedTask = Task(
                        taskID: widget.task.taskID,
                        description: description, 
                        dueDateTime: date, 
                        title: title,
                        isCompleted: widget.task.isCompleted,
                        priority: priority,
                        notificationTypes: selectedNotificationTypes,
                      );
                      
                      // Update in database
                      await db.updateTask(updatedTask);
                      
                      log("Task updated with ID: ${updatedTask.taskID}");
                      log("Scheduling new notification for: ${updatedTask.dueDateTime}");
                      // Schedule new notification for the updated task
                      await NotificationService().scheduleTaskNotification(updatedTask);
                      
                      log("Task update completed");
                      Navigator.pop(context);
                    } catch (e) {
                      log("Error updating task: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating task: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    log("Missing required fields: title=$title, description=$description, date=$date");
                    // Show error message to user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }, 
                child: Text("Update Task")
              ),
            ],
          )
        ],
      ),
    );
  }
} 