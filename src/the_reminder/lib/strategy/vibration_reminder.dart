import 'package:vibration/vibration.dart';
import 'reminder_strategy.dart';

class VibrationReminder implements ReminderStrategy {
  @override
  void remind({String? message, Map<String, dynamic>? data}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
      final task = data?['taskName'] ?? 'a task';
      print("📳 Vibration reminder for: $task - $message");
    } else {
      print("❌ Vibration not supported");
    }
  }
}