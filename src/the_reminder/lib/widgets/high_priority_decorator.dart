import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/colorful_decorator.dart';

class HighPriorityDecorator extends ColorfulDecorator {
  @override
  // TODO: implement color
  Color get color => const Color.fromARGB(255, 171, 57, 23);
  const HighPriorityDecorator(super.child, {super.color,super.key});

}