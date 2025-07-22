import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/colorful_decorator.dart';

class LowPriorityDecorator extends ColorfulDecorator {
  @override
  // TODO: implement color
  Color get color => const Color.fromARGB(255, 96, 96, 96);
  const LowPriorityDecorator(super.child, {super.color,super.key});

}