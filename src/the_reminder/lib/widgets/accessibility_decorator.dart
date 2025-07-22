import 'package:flutter/cupertino.dart';

class AccessibilityDecorator extends StatelessWidget {
  final Widget child;

  const AccessibilityDecorator(this.child,{super.key});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}