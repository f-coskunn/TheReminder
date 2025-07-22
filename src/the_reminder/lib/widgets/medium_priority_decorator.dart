import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/colorful_decorator.dart';

class MediumPriorityDecorator extends ColorfulDecorator {
  @override
  // TODO: implement color
  Color get color => const Color.fromARGB(0, 255, 235, 59);
  const MediumPriorityDecorator(super.child, {super.color,super.key});

}