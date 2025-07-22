import 'package:flutter/material.dart';
import 'reminder_strategy.dart';

class VisualReminder implements ReminderStrategy {
  final BuildContext context;

  VisualReminder(this.context);

  @override
  void remind({String? message, Map<String, dynamic>? data}) {
    final task = data?['taskName'] ?? 'a task';
    final msg = message ?? "You have a reminder";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("🔔 $msg: $task")),
    );
    print("👁 Visual reminder shown for: $task - $msg");
  }
}