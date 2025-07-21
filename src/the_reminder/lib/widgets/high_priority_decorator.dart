import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/colorful_decorator.dart';

class HighPriorityDecorator extends ColorfulDecorator {
  @override
  // TODO: implement color
  Color get color => Colors.red;
  const HighPriorityDecorator(super.child, {super.color=Colors.red,super.key});

}