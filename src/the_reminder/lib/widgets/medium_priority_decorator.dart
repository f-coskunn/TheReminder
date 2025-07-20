import 'package:flutter/material.dart';
import 'package:the_reminder/widgets/colorful_decorator.dart';

class MediumPriorityDecorator extends ColorfulDecorator {
  @override
  // TODO: implement color
  Color get color => Colors.yellow;
  const MediumPriorityDecorator(super.child, {super.color=Colors.yellow,super.key});

}