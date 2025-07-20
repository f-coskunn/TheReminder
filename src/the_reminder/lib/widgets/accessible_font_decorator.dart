import 'package:flutter/cupertino.dart';
import 'package:the_reminder/widgets/accessibility_decorator.dart';

class FontDecorator extends AccessibilityDecorator {
  final double fontSize;

  const FontDecorator(super.child,{this.fontSize = 1.5, super.key});

  @override
  Widget build(BuildContext context) {
    //Scale the text
    final t = TextScaler.linear(fontSize);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: t), 
      child: child
    );
  }
}