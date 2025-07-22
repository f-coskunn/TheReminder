import 'reminder_strategy.dart';

/// Combines multiple ReminderStrategy implementations.
/// When `remind` is called, all strategies will be triggered.
class CompositeReminder implements ReminderStrategy {
  final List<ReminderStrategy> _strategies;

  /// Provide a list of strategies to be executed in sequence.
  CompositeReminder(this._strategies);

  @override
  void remind({String? message, Map<String, dynamic>? data}) {
    for (final strategy in _strategies) {
      strategy.remind(message: message, data: data);
    }
  }
}