import 'observer.dart';

// Subject interface for observable objects
abstract class Subject {
  void attach(Observer observer);
  void detach(Observer observer);
  void notify(String message, Map<String, dynamic> data);
} 