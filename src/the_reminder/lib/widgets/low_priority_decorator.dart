import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/colorful_decorator.dart';

class LowPriorityDecorator extends ColorfulDecorator {
  @override
  // TODO: implement color
  Color get color => Colors.lightGreenAccent;
  const LowPriorityDecorator(super.child, {super.color=Colors.lightGreenAccent,super.key});

}