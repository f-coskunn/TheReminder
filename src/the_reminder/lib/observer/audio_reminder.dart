import 'package:audioplayers/audioplayers.dart';
import 'reminder_strategy.dart';

class AudioReminder implements ReminderStrategy {
  final AudioPlayer _player = AudioPlayer();

  @override
  void remind({String? message, Map<String, dynamic>? data}) async {
    await _player.play(AssetSource('sounds/reminder_sound.mp3'));
    final task = data?['taskName'] ?? 'a task';
    print("🔊 Audio reminder: $task - $message");
  }
}