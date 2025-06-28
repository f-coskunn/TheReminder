//Model için geçici placeholder class
//TODO: asıl model ile değiştirilecek
class Task {
  
  String description;
  String reminder;
  bool completed;

  Task({required this.description, required this.reminder, this.completed = false} );
  
  set setCompleted(bool c)=>completed=c;

  @override
  String toString() {
    return "Description:$description\nReminder:$reminder\nCompleted:$completed";
  }
}