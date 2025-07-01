enum ReminderType { vibrate, notification, audio }

class Reminder {
  int taskID;
  ReminderType reminderType;

  Reminder({
    required this.taskID,
    this.reminderType = ReminderType.notification,
  });

  Map<String, dynamic> toMap() {
    return {'taskID': taskID, 'reminder': _reminderToString(reminderType)};
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      taskID: map['taskID'],
      reminderType: _reminderFromString(map['reminderType'] ?? 'Notification'),
    );
  }

  @override
  String toString() {
    return 'Reminder(taskID: $taskID, reminder: $reminderType)';
  }

  String _reminderToString(ReminderType p) => p.name;

  // Converts string to enum
  static ReminderType _reminderFromString(String s) {
    switch (s.toLowerCase()) {
      case 'Vibrate':
        return ReminderType.vibrate;
      case 'Audio':
        return ReminderType.audio;
      default:
        return ReminderType.notification;
    }
  }
}
