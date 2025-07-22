// contrast_decorator.dart
import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/accessibility_decorator.dart';

//Wraps a child with themed material app
class ContrastDecorator extends AccessibilityDecorator {
  ContrastDecorator(super.child);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      home: child,
    ) ;
  }
}
